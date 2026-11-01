#!/usr/bin/env python3
"""修正原稿新旧対照表 (JSCE) を Word (.docx) で生成する.

使い方:
    python3 make_response_table.py

同じディレクトリに 修正原稿新旧対照表.docx を出力する.
回答文を直したいときは下の ANSWERS を編集して再実行すればよい.
"""

from pathlib import Path

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.shared import Mm, Pt

# ---------------------------------------------------------------- 体裁設定
JP_FONT = "Hiragino Mincho ProN"   # 和文フォント. Windows で開くなら "ＭＳ 明朝" などに変更
ASCII_FONT = "Times New Roman"     # 欧文フォント
BASE_PT = 10.5

META = {
    "journal": "土木学会論文集特集号（水工学）",
    "committee": "土木学会論文集特集号（水工学）編集小委員会",
    "first_author": "小柴 孝太",
    "corresponding_author": "小柴 孝太",
    "title": "SLSC に基づく水文頻度解析の適合度評価に関する統計的再検討",
}

# ---------------------------------------------------------------- 回答文
# ここを編集すれば対照表の【回答】が変わる.
ANSWERS = {
    "R1-1": "ご指摘の通り, C1級関数の簡単な説明を2.(2)の式(3)の直前に追加しました。",

    "R2-1": "ご指摘の通りでした。文献5)を初出順に合わせて移動し, "
            "参考文献の並びを本文中の初出順に修正しました。",

    "R2-2": "ご指摘を踏まえ, 和文要旨および英文要旨に, ずれを雨量そのものの軸で測るのがX空間, "
            "確率紙上の軸で測るのがS空間である旨を明記しました。",

    "R2-3": "表-1の定義は実務と異なるものを新たに設けたものではなく, "
            "日本の実務で用いられてきた確率紙の座標に対応するものです。その旨を2.(1)に明記しました。"
            "あわせて, 形状母数を含む別定義を用いればGEVやSqrtEtも非線形標準化となるため, "
            "本稿の結果は表-1の定義を前提とする旨を明記しました。",

    "R2-4": "ご指摘を踏まえ, 実務におけるSLSCは確率紙上, すなわちS空間で評価されている旨を"
            "2.(1)に明記しました。標準変量は表-1に示したものです。",

    "R2-5": "ご指摘の通り, LP3も対数を含む標準変量をもつため同じ影響を受けます。"
            "LN3に固有の問題ではなく非線形標準化に共通する問題である旨を2.(1)に明記しました。"
            "LN3はその代表例としてX空間評価を併記したものです。",

    "R2-6": "ご指摘を踏まえ, 2.(4)に, 全条件で同一の式を用いているため比較には影響しないが, "
            "SLSCの絶対値は式の選択に依存する旨を明記しました。",

    "R2-7": "ご指摘の通り修正しました。縦軸の範囲と目盛位置を6つのパネルで共通化し, "
            "あわせてキャプションに両対数目盛である旨を明記しました。",

    "R2-8": "ご指摘の通り修正しました。",

    "R2-9": "ご指摘を踏まえ, 4章の第一の点が既往研究で既に指摘されている内容であり, "
            "本稿の寄与はこれが6分布でも維持されることを確認した点にあることを明記しました。",

    "R3-1": "ご指摘の通り修正しました。本文中の図表参照の書体をキャプションと一致させ, "
            "表-1と表-2の文字サイズを揃えました。"
            "あわせて, 相互参照等に枠線が印刷される設定を修正しました。",

    "R3-2": "ご指摘の通り修正しました。S, Xをすべて数式斜体に統一しました。",

    "R3-3": "ご指摘の通り修正しました。初出箇所を"
            "「赤池情報量規準 (Akaike Information Criterion, AIC)」としました。",

    "R3-4": "ご指摘の通り修正しました。式(1)をSLSCs, 式(2)をSLSCxとし, "
            "本文中でも同じ記号を用いるようにしました。",

    "R3-5": "ご指摘の通り修正しました。",

    "R3-6": "説明が不足しておりました。AICはSLSCを用いず, またSLSC+ジャックナイフ法でも"
            "最終選択はジャックナイフ幅の最小化で行われるため, SLSCが小さいことが直ちに"
            "採択集中には結びつきません。この旨を3.(3)に加筆しました。",
}

# ---------------------------------------------------------------- 査読意見（原文）
REVIEWERS = [
    {
        "n": 1,
        "items": [
            {
                "key": "R1-1",
                "no": "1",
                "cat": "B",
                "loc": "p.3 左段, 下から3行目",
                "comment": "C1級関数について無知な読者が多いと思いますので，"
                           "簡単な解説をお願いします",
            },
        ],
    },
    {
        "n": 2,
        "items": [
            {
                "key": "R2-1",
                "no": "1",
                "cat": "C",
                "loc": "はじめに",
                "comment": "文献5)が6）の後に出ているかと思います。"
                           "順番にそって記述して下さい。",
            },
            {
                "key": "R2-2",
                "no": "2",
                "cat": "A",
                "loc": "アブストラクト",
                "comment": "X空間、S空間は本研究の重要な要素ではあるものの、"
                           "現在の書き方ではこの分野に詳しくない多くの読者は理解できないと思います。"
                           "限られた文字数での説明は難しいと思いますが、"
                           "それでも要旨だけで多くの読者が扱っている内容を理解できるように"
                           "記述されるのを望みます。",
            },
            {
                "key": "R2-3",
                "no": "3",
                "cat": "A",
                "loc": "表1",
                "comment": "ここでは「比較用の簡易定義」と書かれていますが、"
                           "実際に実務上使われているものと異なるのでしょうか。"
                           "仮に簡易定義ということで実務と異なるものを使っている場合には、"
                           "それが結論に与える影響はないのでしょうか。"
                           "結果が異なる場合は、この論文から言えることは簡易定義による結論である"
                           "ことを明記する必要があるように思います。",
            },
            {
                "key": "R2-4",
                "no": "4",
                "cat": "A",
                "loc": "表1",
                "comment": "実務上で扱われているSLSCがX空間とS空間のどちらか、"
                           "また標準変量は何かという点についても説明を含めてはどうでしょうか。",
            },
            {
                "key": "R2-5",
                "no": "5",
                "cat": "A",
                "loc": "表1",
                "comment": "表1においては、LP3についてもX空間とS空間の違いによる影響が"
                           "ありそうですが、LP3を扱わない理由は何かあるのでしょうか。"
                           "非線形標準化一般の問題か、LN3固有の問題かという議論は不要でしょうか。",
            },
            {
                "key": "R2-6",
                "no": "6",
                "cat": "A",
                "loc": "2(4)",
                "comment": "プロッティングポジションはカナン式を使っていますが、"
                           "この選択は結果に影響を及ぼさないでしょうか？"
                           "他が詳細な検討なので、この部分の影響を無視して良いかという点は"
                           "少なくとも言及が必要なのではないでしょうか。",
            },
            {
                "key": "R2-7",
                "no": "7",
                "cat": "B",
                "loc": "図2",
                "comment": "それぞれの分布の減少率に応じて縦軸を設定しているのだと思いますが、"
                           "逆にやや紛らわしいように思います。"
                           "全て同じように書くと図として意味をなさないようになってしまうのだとは"
                           "想像するのですが、特に対数とそうでないものが混じるのは誤解を生じそうです。"
                           "いまいちどこれで良いかどうかをご検討ください。",
            },
            {
                "key": "R2-8",
                "no": "8",
                "cat": "C",
                "loc": "図3, 4",
                "comment": "やや図中の文字が小さく判読が困難かと思います。"
                           "サイズの調整をお願いします。",
            },
            {
                "key": "R2-9",
                "no": "9",
                "cat": "A",
                "loc": "4. 考察",
                "comment": "本研究により得られた結果と、既に既往研究によりわかった結果の区別が"
                           "不明瞭なまま説明されているように感じます。"
                           "第一の点は既に既往の研究等でも指摘されている内容かと思います。"
                           "考察としては、あくまでもこの研究としてわかったことを軸に"
                           "説明されるのが望ましく思います。"
                           "既往の研究成果と本研究の成果を合わせて、現在わかっていることを"
                           "まとめるということであれば、5.結論に記載してはどうでしょうか。",
            },
        ],
    },
    {
        "n": 3,
        "items": [
            {
                "key": "R3-1",
                "no": "1",
                "cat": "A",
                "loc": "全般",
                "comment": "所定のフォント（種類・サイズ）を用いてください．"
                           "とくに見出しやキャプション（図-**など）で異なるフォントが"
                           "用いられている箇所が散見されます．",
            },
            {
                "key": "R3-2",
                "no": "2",
                "cat": "A",
                "loc": "全般",
                "comment": "「S空間，X空間」のSやXの表記で立体と斜体が混在していますので，"
                           "統一して下さい．",
            },
            {
                "key": "R3-3",
                "no": "3",
                "cat": "A",
                "loc": "p.2, 左段, 上から12行目",
                "comment": "後に単独でAICと記述されている箇所がありますので，"
                           "「情報量基準（AIC）」など略語の意味を明記して下さい．",
            },
            {
                "key": "R3-4",
                "no": "4",
                "cat": "B",
                "loc": "p.2, 右段, 下から18行目",
                "comment": "式（2）では「SLSCx」となっているので，"
                           "本文中もこれに統一したほうが良いと思います．",
            },
            {
                "key": "R3-5",
                "no": "5",
                "cat": "C",
                "loc": "p.3, 図-1",
                "comment": "「Standardised」，「Normalised」は，"
                           "それぞれ「Standardized」，「Normalized」",
            },
            {
                "key": "R3-6",
                "no": "6",
                "cat": "A",
                "loc": "p.5, 右段, 下から11行目",
                "comment": "LN3ではSLSCが小さく評価される傾向がありながら，"
                           "採択集中がみられなかったのは何故でしょうか？"
                           "採択手順と関係すると思われますが，もう少し説明が必要です．",
            },
        ],
    },
]


# ---------------------------------------------------------------- 生成
def style_run(run, size=BASE_PT, bold=False):
    run.font.size = Pt(size)
    run.font.name = ASCII_FONT
    run.bold = bold
    rPr = run._element.get_or_add_rPr()
    rFonts = rPr.get_or_add_rFonts()
    rFonts.set(qn("w:eastAsia"), JP_FONT)
    rFonts.set(qn("w:ascii"), ASCII_FONT)
    rFonts.set(qn("w:hAnsi"), ASCII_FONT)
    return run


def add_par(doc, align=WD_ALIGN_PARAGRAPH.LEFT, space_after=4, space_before=0,
            indent=None, first_indent=None):
    p = doc.add_paragraph()
    p.alignment = align
    pf = p.paragraph_format
    pf.space_after = Pt(space_after)
    pf.space_before = Pt(space_before)
    pf.line_spacing = 1.15
    if indent is not None:
        pf.left_indent = Mm(indent)
    if first_indent is not None:
        pf.first_line_indent = Mm(first_indent)
    return p


def build(out_path: Path) -> Path:
    doc = Document()

    sec = doc.sections[0]
    sec.page_width, sec.page_height = Mm(210), Mm(297)
    sec.top_margin = sec.bottom_margin = Mm(25)
    sec.left_margin = sec.right_margin = Mm(22)

    normal = doc.styles["Normal"]
    normal.font.name = ASCII_FONT
    normal.font.size = Pt(BASE_PT)
    normal.element.rPr.rFonts.set(qn("w:eastAsia"), JP_FONT)

    # ---- 表題
    p = add_par(doc, WD_ALIGN_PARAGRAPH.CENTER, space_after=6)
    style_run(p.add_run(META["journal"]), size=13, bold=True)

    p = add_par(doc, WD_ALIGN_PARAGRAPH.CENTER, space_after=8)
    style_run(p.add_run("修正原稿新旧対照表"), size=15, bold=True)

    p = add_par(doc, WD_ALIGN_PARAGRAPH.CENTER, space_after=16)
    style_run(p.add_run(META["committee"]), size=10.5)

    # ---- 著者情報
    for label, key in (("First Author", "first_author"),
                       ("Corresponding Author", "corresponding_author"),
                       ("Title", "title")):
        p = add_par(doc, space_after=2)
        style_run(p.add_run(f"●{label}：{META[key]}"), bold=True)

    # ---- 査読者ごと
    for rv in REVIEWERS:
        p = add_par(doc, space_before=14, space_after=6)
        style_run(p.add_run(f"※※※　査読者　{rv['n']}："), size=11.5, bold=True)

        for it in rv["items"]:
            head = f"（{it['no']}. {it['cat']}, {it['loc']}）"
            p = add_par(doc, space_after=3, indent=3, first_indent=-3)
            style_run(p.add_run("【修正意見】"), bold=True)
            style_run(p.add_run(head + it["comment"]))

            answer = ANSWERS.get(it["key"], "") or "（未記入）"
            p = add_par(doc, space_after=9, indent=3, first_indent=-3)
            style_run(p.add_run("【回答】"), bold=True)
            style_run(p.add_run("　" + answer))

    doc.save(out_path)
    return out_path


if __name__ == "__main__":
    out = Path(__file__).resolve().parent / "修正原稿新旧対照表.docx"
    build(out)
    print(f"Wrote {out}")
