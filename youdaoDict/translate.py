""" translate words by youdao dict """
# Author: slivermeteor
# -*- coding: utf-8 -*-
import re
import argparse
from html import unescape
from abc import ABC, abstractmethod
import requests
from requests.utils import requote_uri


class Trans(ABC):
    """ translate abstract class """
    line_pattern = ""
    pos_pattern = ""
    trans_pattern = ""
    lang = ""

    def get_match_line(self, text: str) -> list:
        """ get match line from text """
        return re.findall(
            f'{self.line_pattern}', text, re.S)

    @abstractmethod
    def output_trans_res(self, match_list: list, verbose: bool):
        """ output translate result """

    def do_trans(self, words: str, verbose: bool):
        """ do translate """
        res = requests.get(
            url=requote_uri(f'https://dict.youdao.com/result?word={words}&lang={self.lang}'), timeout=5)

        if not res.ok:
            print(f'req youdao dict failed! http code: {res.status_code}')
            return

        if verbose:
            with open('temp.html', 'w', encoding='utf-8') as f:
                f.write(res.text)

        match_list = self.get_match_line(res.text)

        if len(match_list) == 0:
            if verbose:
                print(f'lang: {self.lang} search failed.')
            return False

        return self.output_trans_res(match_list, verbose)


class EN2CNTrans(Trans):
    """ en translate to cn class """
    line_pattern = r'<li class="word-exp"[^>]*>(.*?)</li>'
    pos_pattern = r'<span class="pos"[^>]*>(.*?)</span>'
    trans_pattern = r'<span class="trans"[^>]*>(.*?)</span>'
    lang = "en"

    def output_trans_res(self, match_list: list, verbose: bool):
        """ output translate result """
        for item in match_list:
            if verbose:
                print(f'result match html: {item}')
            pos = re.search(f'{self.pos_pattern}', item, re.S)
            trans = re.search(
                f'{self.trans_pattern}', item, re.S)

            if not pos or not trans:
                return False

            print(f'{pos.group(1)}{unescape(trans.group(1))}')

        return True


class ENWordGroup2CNTrans(EN2CNTrans):
    """ en word group translate to chinese """

    def output_trans_res(self, match_list: list, verbose: bool):
        """ output translate result """
        for item in match_list:
            if verbose:
                print(f'result match html: {item}')
            trans = re.search(
                f'{self.trans_pattern}', item, re.S)

            if not trans:
                return False

            print(f'{unescape(trans.group(1))}')

        return True


class CN2ENTrans(Trans):
    """ cn translate to en class """
    line_pattern = r'<div class="trans-ce"[^>]*>(.*?)</div>'
    trans_pattern = r'<a class="point"[^>]*>(.*?)</a>'
    lang = "en"

    def output_trans_res(self, match_list: list, verbose: bool):
        index = 1
        for item in match_list:
            if verbose:
                print(f'result match html: {item}')
            word = re.search(f'{self.trans_pattern}', item, re.S)

            if not word:
                return False

            print(f'{index}.{word.group(1)}')
            index += 1

        return True


def main():
    """ main function"""
    parser = argparse.ArgumentParser()
    parser.add_argument('--words', type=str,
                        help='translate words', default='')
    parser.add_argument("-v",
                        "--verbose", help="increase output verbosity", action="store_true")
    args = parser.parse_args()

    if EN2CNTrans().do_trans(args.words, args.verbose):
        return

    if ENWordGroup2CNTrans().do_trans(args.words, args.verbose):
        return

    if CN2ENTrans().do_trans(args.words, args.verbose):
        return

    print("Can't find any translation about your input.")
    print("Please check out your input. :D")

    return


if __name__ == '__main__':
    main()
