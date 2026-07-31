#!/usr/bin/env python3
"""Deck order audit -- canonical check for every BTLI/Usbong lesson deck.

WHY THIS EXISTS. Lesson decks carry a printed running number ("7 / 21") baked
into the slide text, because a facilitator runs the class from the slides alone
and needs to know where they are. When questions are inserted into an existing
deck, that number and the slide's actual position can drift apart -- and the
facilitator finds out in front of the class.

THE TRAP THIS AVOIDS. PowerPoint does NOT store running order in the slide part
filenames. It stores it in ppt/presentation.xml's <p:sldIdLst>, resolved through
ppt/_rels/presentation.xml.rels. A slide inserted third is still slide17.xml on
disk. Auditing by filename reports every slide after the insertion point as
misordered -- a false alarm that once cost a review of PR #283, where 19 of 21
slides were declared broken and all 21 were in fact correct.

  A defect uniform across everything you measured is more likely a fault in the
  measurement than in the thing measured.

Usage:  python3 check_slide_order.py <deck.pptx> [deck2.pptx ...]
Exit 0 = all decks clean. Exit 1 = at least one real misordering.
"""
import re, sys, zipfile

def audit(path):
    z = zipfile.ZipFile(path)
    pres = z.read('ppt/presentation.xml').decode('utf-8', 'replace')
    rels = z.read('ppt/_rels/presentation.xml.rels').decode('utf-8', 'replace')
    rid2part = dict(re.findall(r'Id="([^"]+)"[^>]*Target="(slides/slide\d+\.xml)"', rels))
    lst = re.search(r'<p:sldIdLst>(.*?)</p:sldIdLst>', pres, re.S)
    if not lst:
        return path, None, ['no <p:sldIdLst> -- not a slide deck?']
    ids = re.findall(r'<p:sldId[^>]*r:id="([^"]+)"[^>]*/>', lst.group(1))
    n = len(ids)
    problems, labelled = [], 0
    for i, rid in enumerate(ids, 1):
        part = rid2part.get(rid)
        if not part:
            problems.append('deck position %d: r:id %s resolves to no slide part' % (i, rid)); continue
        txt = ' '.join(re.findall(r'<a:t>(.*?)</a:t>',
                                  z.read('ppt/' + part).decode('utf-8', 'replace'), re.S))
        m = re.search(r'(\d+)\s*/\s*' + str(n) + r'\b', txt)
        if not m:
            continue                      # slide carries no running number; not an error
        labelled += 1
        printed = int(m.group(1))
        if printed != i:
            problems.append('deck position %d (%s) prints "%d / %d"'
                            % (i, part.split('/')[-1], printed, n))
    # A deck where NO slide is numbered cannot be verified -- say so rather than pass it.
    if labelled == 0:
        problems.append('no slide carries an "N / %d" running number; order is unverifiable' % n)
    return path, n, problems

def main(argv):
    if not argv:
        print(__doc__); return 2
    bad = 0
    for p in argv:
        path, n, problems = audit(p)
        name = path.split('/')[-1]
        if problems:
            bad += 1
            print('FAIL  %-28s %s slides' % (name, n))
            for pr in problems:
                print('        - ' + pr)
        else:
            print('PASS  %-28s %2d slides, running numbers match deck order' % (name, n))
    print()
    print('%d deck(s) checked, %d with problems' % (len(argv), bad))
    return 1 if bad else 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
