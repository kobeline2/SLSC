%%%
%%% このクラスファイルの著作権は土木学会が有します．
%%% このクラスファイルを土木学会論文集の原稿作成以外の目的で使用することを禁止します．
%%% また，無断での複製、改変、転載、再配布及び転送等の行為を禁止します
%%% 使い方に関するお問い合わせは応用力学委員会編集小委員会LaTeX WG(jjsce-latex@jsce.or.jp）にお願いします．
%%% LaTeXのクラスファイル作成に関するお問い合わせは（株）ウルス（teppei@uls.co.jp）にお願いします．
%%% jjsce.cls for (u)pLaTeX2e+LuaTeX
%%   for the Journal of the Japan Society of Civil Engineers
%%     by Motoaki Sato (ULS and Company), 2022
%%     E-mail: teppei@uls.co.jp, http://www.uls.co.jp/
\ifx\directlua\@undefined
 \NeedsTeXFormat{pLaTeX2e}
\else
 \NeedsTeXFormat{LaTeX2e}
\fi
\ProvidesClass{jjsce}
%%[2022/05/30 v1.0 for 土木学会論文集]
%% Keywords を Key Words に変更
%%[2022/10/17 v1.1 for 土木学会論文集]
%% \refname と \notesname をボールドに修正
  [2022/11/09 v1.2 for 土木学会論文集]

\def\jsce@warning{\ClassWarningNoLine{jjsce}}
\def\jsceline@warning{\ClassWarning{jjsce}}

\newif\if@enable@uptex \@enable@uptexfalse
\ifx\directlua\@undefined
 \def\kenc@jjsce{JY2}
 \ifx\kenc@jjsce\cy@encoding
  \@enable@uptextrue
 \fi
 %%
 %\def\zw{zw}%
 %\def\zh{zh}%
 \def\jjsce@kanjiskip#1{\kanjiskip#1}
 \def\jjsce@xkanjiskip#1{\xkanjiskip#1}% for kintou
\else
 \@enable@uptextrue
 \RequirePackage{luatexja}%
 %\RequirePackage{luatexja-fontspec}
 \def\jjsce@kanjiskip#1{\ltjsetparameter{kanjiskip=#1}}
 \def\jjsce@xkanjiskip#1{\ltjsetparameter{xkanjiskip=#1}}% for kintou
\fi

\newif\if@english \@englishfalse
\DeclareOption{english}{\@englishtrue}

\newif\if@noflushend \@noflushendfalse
\DeclareOption{noflushend}{\@noflushendtrue}

\newif\if@jscefinal \@jscefinalfalse
\DeclareOption{jscefinal}{\@jscefinaltrue}

\newif\if@tinymathskip \@tinymathskipfalse
\DeclareOption{tinymathskip}{\@tinymathskiptrue}
\newif\if@smallmathskip \@smallmathskipfalse
\DeclareOption{smallmathskip}{\@smallmathskiptrue}

\newif\if@Proof \@Prooffalse
\DeclareOption{Proof}{\@Prooftrue}

\newcounter{@paper}
%\newif\if@landscape \@landscapefalse
\newcommand{\@ptsize}{}
\newif\if@restonecol
\newif\if@titlepage
\@titlepagefalse

\hour\time \divide\hour by 60\relax
\@tempcnta\hour \multiply\@tempcnta 60\relax
\minute\time \advance\minute-\@tempcnta
\newif\if@stysize \@stysizefalse
\newif\if@enablejfam \@enablejfamtrue
\newif\if@mathrmmc \@mathrmmcfalse
\DeclareOption{a4paper}{\setcounter{@paper}{1}%
  \setlength\paperheight {297mm}%
  \setlength\paperwidth  {210mm}}
%\DeclareOption{a4p}{\setcounter{@paper}{1}\@stysizetrue
%  \setlength\paperheight {297mm}%
%  \setlength\paperwidth  {210mm}}
\DeclareOption{10pt}{\renewcommand{\@ptsize}{0}}
\DeclareOption{11pt}{\renewcommand{\@ptsize}{1}}
\DeclareOption{12pt}{\renewcommand{\@ptsize}{2}}
%\DeclareOption{landscape}{\@landscapetrue
%  \setlength\@tempdima{\paperheight}%
%  \setlength\paperheight{\paperwidth}%
%  \setlength\paperwidth{\@tempdima}}
\DeclareOption{tombow}{%
  \tombowtrue \tombowdatetrue
  \setlength{\@tombowwidth}{.1\p@}%
  \@bannertoken{%
     \jobname\space(\number\year-\two@digits\month-\two@digits\day
     \space\two@digits\hour:\two@digits\minute)}%
  \maketombowbox}
\DeclareOption{tombo}{%
  \tombowtrue \tombowdatefalse
  \setlength{\@tombowwidth}{.1\p@}%
  \maketombowbox}
\DeclareOption{mentuke}{%
  \tombowtrue \tombowdatefalse
  \setlength{\@tombowwidth}{\z@}%
  \maketombowbox}
\DeclareOption{tate}{%
  \AtBeginDocument{\tate\message{《縦組モード》}%
                   \adjustbaseline}%
}
\DeclareOption{oneside}{\@twosidefalse}
\DeclareOption{twoside}{\@twosidetrue}
\DeclareOption{onecolumn}{\@twocolumnfalse}
\DeclareOption{twocolumn}{\@twocolumntrue}
\DeclareOption{titlepage}{\@titlepagetrue}
\DeclareOption{notitlepage}{\@titlepagefalse}
\DeclareOption{leqno}{\input{leqno.clo}}
\DeclareOption{fleqn}{\input{fleqn.clo}}
\DeclareOption{openbib}{%
  \AtEndOfPackage{%
   \renewcommand\@openbib@code{%
      \advance\leftmargin\bibindent
      \itemindent -\bibindent
      \listparindent \itemindent
      \parsep \z@
      }%
   \renewcommand\newblock{\par}}}
\DeclareOption{disablejfam}{\@enablejfamfalse}
\DeclareOption{mathrmmc}{\@mathrmmctrue}
\DeclareOption{draft}{\setlength\overfullrule{5pt}}
\DeclareOption{final}{\setlength\overfullrule{0pt}}
\ExecuteOptions{a4paper,10pt,twoside,twocolumn,final}
\ProcessOptions\relax

%%% 和文フォントは後回し
\edef\kenc@JYn{\cy@encoding}
\edef\kenc@JTn{\ct@encoding}%\typeout{!!! \kenc@JTn}% 2012 OK

\def\Cjascale{1}% 0.924714

\ifx\directlua\@undefined
 \if@enable@uptex
  \DeclareFontShape{JY2}{mc}{m}{n}{%
    <-> s * [1] upjisr-h
  }{}
  \DeclareFontShape{JY2}{gt}{m}{n}{% 
    <-> s * [1] upjisg-h
  }{}
  \DeclareFontShape{JT2}{mc}{m}{n}{%
    <-> s * [1] upjisr-v
  }{}
  \DeclareFontShape{JT2}{gt}{m}{n}{% 
    <-> s * [1] upjisg-v
  }{}
 \else
  %% ?pt (実際の大きさ)  (実際の大きさ x 1.0392687)
  \DeclareFontShape{JY1}{mc}{m}{n}{%
    <-> s * [1.0392687] jis
  }{}
  \DeclareFontShape{JY1}{gt}{m}{n}{%
    <-> s * [1.0392687] jisg
  }{}
  \DeclareFontShape{JT1}{mc}{m}{n}{%
    <-> s * [1.0392687] jis-v
  }{}
  \DeclareFontShape{JT1}{gt}{m}{n}{%
    <-> s * [1.0392687] jisg-v
  }{}
 \fi
\else
\DeclareFontShape{JY3}{mc}{m}{n}{%
  <-> s*[1]\ltj@stdmcfont:jfm=ujis
}{}
\DeclareFontShape{JY3}{gt}{m}{n}{%
  <->s*[1]\ltj@stdgtfont:jfm=ujis
}{}
%%%
\DeclareFontShape{JT3}{mc}{m}{n}{%
  <-> s*[1]\ltj@stdmcfont:jfm=ujisv
}{}
\DeclareFontShape{JT3}{gt}{m}{n}{%
  <->s*[1]\ltj@stdgtfont:jfm=ujisv
}{}
\fi

\DeclareFontShape{\kenc@JYn}{mc}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JYn}{gt}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JYn}{mc}{b}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JYn}{mc}{b}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JYn}{mc}{m}{it}{<->ssub*mc/m/n}{}
\DeclareFontShape{\kenc@JYn}{mc}{m}{sl}{<->ssub*mc/m/n}{}
\DeclareFontShape{\kenc@JYn}{mc}{m}{sc}{<->ssub*mc/m/n}{}
\DeclareFontShape{\kenc@JYn}{gt}{m}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JYn}{gt}{m}{sl}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JYn}{mc}{bx}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JYn}{mc}{bx}{sl}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JYn}{mc}{b}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JYn}{mc}{b}{sl}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JTn}{mc}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JTn}{gt}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JTn}{mc}{b}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JTn}{mc}{b}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JTn}{mc}{m}{it}{<->ssub*mc/m/n}{}
\DeclareFontShape{\kenc@JTn}{mc}{m}{sl}{<->ssub*mc/m/n}{}
\DeclareFontShape{\kenc@JTn}{mc}{m}{sc}{<->ssub*mc/m/n}{}
\DeclareFontShape{\kenc@JTn}{gt}{m}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JTn}{gt}{m}{sl}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JTn}{mc}{bx}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JTn}{mc}{bx}{sl}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JTn}{mc}{b}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{\kenc@JTn}{mc}{b}{sl}{<->ssub*gt/m/n}{}
\ifx\directlua\@undefined\else
\renewcommand\jttdefault{\gtdefault}\@ltj@match@familytrue
\fi

\ifx\directlua\@undefined
 \def\@setfontsize#1#2#3{\@nomath#1%
  \ifx\protect\@typeset@protect
    \let\@currsize#1%
  \fi
  \fontsize{#2}{#3}\selectfont
  \kanjiskip=0zw \@plus .1zw \@minus .025zw
  \xkanjiskip=0.25em \@plus 0.15em \@minus 0.06em
 }%
\else
 \def\@setfontsize#1#2#3{%
 %\@nomath#1%
  \ifx\protect\@typeset@protect
    \let\@currsize#1%
  \fi
  \fontsize{#2}{#3}\selectfont
  %\ifdim\parindent>\z@
  %  \parindent10\p@
  %\fi
  \ltj@setpar@global
  \ltjsetkanjiskip\z@ plus .1\zw minus .025\zw
  \@tempskipa=\ltjgetparameter{xkanjiskip}
  \ifdim\@tempskipa>\z@
   %\if@slide
   % \ltjsetxkanjiskip .1em
   %\else
    \ltjsetxkanjiskip .25em plus .15em minus .06em
   %\fi
  \fi}
\fi

% <jsize10.clo>
\if@english
\renewcommand{\normalsize}{%
 \@setfontsize\normalsize\@xipt{4.5mm}% 18H
 \abovedisplayskip.5\Cvs \@plus.25\Cvs \@minus.15\Cvs
 \abovedisplayshortskip\z@ \@plus.15\Cvs
 \belowdisplayshortskip.3\Cvs \@plus.15\Cvs \@minus.1\Cvs
 \belowdisplayskip \abovedisplayskip
 \let\@listi\@listI}
\else
\renewcommand{\normalsize}{%
 \@setfontsize\normalsize\@xpt{15}%
 \abovedisplayskip.5\Cvs \@plus.25\Cvs \@minus.15\Cvs
 \abovedisplayshortskip\z@ \@plus.15\Cvs
 \belowdisplayshortskip.3\Cvs \@plus.15\Cvs \@minus.1\Cvs
 \belowdisplayskip \abovedisplayskip
 \let\@listi\@listI}
\fi
\normalsize
\ifx\MakeRobust\@undefined \else
  \MakeRobust\normalsize
\fi
\setbox0\hbox{\char\jis"3441}% "
\setlength\Cht{\ht0}
\setlength\Cdp{\dp0}
\setlength\Cwd{\wd0}
\setlength\Cvs{\baselineskip}
\setlength\Chs{\wd0}
\setbox0=\box\voidb@x

\DeclareRobustCommand{\small}{%
 \@setfontsize\small\@ixpt{12}% abstract, references
 \abovedisplayskip.5\baselineskip
   \@plus.25\baselineskip \@minus.15\baselineskip
 \abovedisplayshortskip\z@ \@plus.15\baselineskip
 \belowdisplayshortskip.3\baselineskip
  \@plus.15\baselineskip \@minus.1\baselineskip
 \belowdisplayskip \abovedisplayskip
 \def\@listi{\leftmargin\leftmargini
             \topsep 4\p@ \@plus2\p@ \@minus2\p@
             \parsep 2\p@ \@plus\p@ \@minus\p@
             \itemsep \parsep}%
 \belowdisplayskip \abovedisplayskip}

\DeclareRobustCommand{\footnotesize}{%
  \@setfontsize\footnotesize\@viiipt{9.5}% ??
  \abovedisplayskip 6\p@ \@plus2\p@ \@minus4\p@
  \abovedisplayshortskip \z@ \@plus\p@
  \belowdisplayshortskip 3\p@ \@plus\p@ \@minus2\p@
  \def\@listi{\leftmargin\leftmargini
              \topsep 3\p@ \@plus\p@ \@minus\p@
              \parsep 2\p@ \@plus\p@ \@minus\p@
              \itemsep \parsep}%
  \belowdisplayskip \abovedisplayskip}

\DeclareRobustCommand{\scriptsize}{\@setfontsize\scriptsize\@viipt\@viiipt}
\DeclareRobustCommand{\tiny}{\@setfontsize\tiny\@vpt\@vipt}
\DeclareRobustCommand{\large}{\@setfontsize\large\@xiipt{17}}
\DeclareRobustCommand{\Large}{\@setfontsize\Large\@xivpt{21}}
\DeclareRobustCommand{\LARGE}{\@setfontsize\LARGE\@xviipt{25}}
\DeclareRobustCommand{\huge}{\@setfontsize\huge\@xxpt{28}}
\DeclareRobustCommand{\Huge}{\@setfontsize\Huge\@xxvpt{33}}

\headheight\z@
\headsep\z@
\topskip 1\Cht
\footskip7mm
\maxdepth .5\topskip
\textwidth170mm % ja eng 同じ 210-(20x2)
%\@settopoint\textwidth
\if@english
\textheight 55\Cvs % 行
\else
\textheight 47\Cvs % 48行
\fi
\advance \textheight \topskip
\advance \textheight .05mm % 頁トップに ()/ などが来ると一行はみ出すことがある
%% 210x297
\topmargin19mm
\advance \topmargin -1in
%\@settopoint\topmargin
\oddsidemargin20mm
\advance \oddsidemargin -1in
%\@settopoint\oddsidemargin
\evensidemargin\oddsidemargin
%\@settopoint\evensidemargin

\setlength\footnotesep{6.65\p@}
\setlength{\skip\footins}{9\p@ \@plus 4\p@ \@minus 2\p@}
%\setlength\floatsep    {12\p@ \@plus 2\p@ \@minus 2\p@}
%\setlength\textfloatsep{20\p@ \@plus 2\p@ \@minus 4\p@}
%\setlength\intextsep   {12\p@ \@plus 2\p@ \@minus 2\p@}
%\setlength\dblfloatsep    {12\p@ \@plus 2\p@ \@minus 2\p@}
%\setlength\dbltextfloatsep{20\p@ \@plus 2\p@ \@minus 4\p@}
\floatsep 1\Cvs \@plus 2\p@ \@minus 2\p@
\dblfloatsep 1\Cvs \@plus 2\p@ \@minus 2\p@
\textfloatsep 1.5\Cvs \@plus 2\p@ \@minus 4\p@
\dbltextfloatsep 1.5\Cvs \@plus 2\p@ \@minus 4\p@
\intextsep 1.5\Cvs \@plus 2\p@ \@minus 2\p@

\setlength\@fptop{0\p@ \@plus 1fil}
\setlength\@fpsep{8\p@ \@plus 2fil}
\setlength\@fpbot{0\p@ \@plus 1fil}
\setlength\@dblfptop{0\p@ \@plus 1fil}
\setlength\@dblfpsep{8\p@ \@plus 2fil}
\setlength\@dblfpbot{0\p@ \@plus 1fil}
\setlength\partopsep{2\p@ \@plus 1\p@ \@minus 1\p@}
\def\@listi{\leftmargin\leftmargini
  \parsep 4\p@ \@plus2\p@ \@minus\p@
  \topsep 8\p@ \@plus2\p@ \@minus4\p@
  \itemsep4\p@ \@plus2\p@ \@minus\p@}
\let\@listI\@listi
\@listi
\def\@listii{\leftmargin\leftmarginii
   \labelwidth\leftmarginii \advance\labelwidth-\labelsep
   \topsep  4\p@ \@plus2\p@ \@minus\p@
   \parsep  2\p@ \@plus\p@  \@minus\p@
   \itemsep\parsep}
\def\@listiii{\leftmargin\leftmarginiii
   \labelwidth\leftmarginiii \advance\labelwidth-\labelsep
   \topsep 2\p@  \@plus\p@\@minus\p@
   \parsep\z@
   \partopsep \p@ \@plus\z@ \@minus\p@
   \itemsep\topsep}
\def\@listiv {\leftmargin\leftmarginiv
              \labelwidth\leftmarginiv
              \advance\labelwidth-\labelsep}
\def\@listv  {\leftmargin\leftmarginv
              \labelwidth\leftmarginv
              \advance\labelwidth-\labelsep}
\def\@listvi {\leftmargin\leftmarginvi
              \labelwidth\leftmarginvi
              \advance\labelwidth-\labelsep}
%% <jsize10.clo>

\setlength\columnsep{6mm}
\setlength\columnseprule{0\p@}
\setlength\lineskip{1\p@}
\setlength\normallineskip{1\p@}
\renewcommand{\baselinestretch}{}
%\setlength\parskip{0\p@ \@plus \p@}
\parskip\z@
\if@english
 \setlength\parindent{11\p@}
\else
 \setlength\parindent{10\p@}
\fi
\@lowpenalty   51
\@medpenalty  151
\@highpenalty 301
\setcounter{topnumber}{5}% 2
\setcounter{bottomnumber}{4}% 1
\setcounter{totalnumber}{9}% 3
\setcounter{dbltopnumber}{5}% 2
\renewcommand{\topfraction}{.95}% .7
\renewcommand{\bottomfraction}{.95}% .3
\renewcommand{\textfraction}{.05}% .2
\renewcommand{\floatpagefraction}{.05}% .5
\renewcommand{\dbltopfraction}{.95}% .7
\renewcommand{\dblfloatpagefraction}{.05}% .5

\if@Proof
 \def\@Rtop{\rlap{\smash{\rule[-\headsep]{0.05mm}{10mm}%
  \rule[-\headsep]{10mm}{0.05mm}}}}
 \def\@Ltop{\llap{\smash{\rule[-\headsep]{10mm}{0.05mm}%
  \rule[-\headsep]{0.05mm}{10mm}}}}
 \def\@Rbot{\rlap{\smash{\raisebox{1\footskip}% v1.06
  {\rule[-10mm]{0.05mm}{10mm}\rule{10mm}{0.05mm}}}}}
 \def\@Lbot{\llap{\smash{\raisebox{1\footskip}% v1.06
  {\rule{10mm}{0.05mm}\rule[-10mm]{0.05mm}{10mm}}}}}
\else
 \let\@Rtop\relax\let\@Ltop\relax\let\@Rbot\relax\let\@Lbot\relax
\fi

\def\nombre@font{\normalfont\small}

\def\received#1#2#3{\def\@temp@m{#2}\ifx \@temp@m\@empty\def\@temp@m{0}\fi
 \def\@recmonth{%
  \ifcase\@temp@m ???\or 
   January\or February\or March\or April\or May\or June\or
   July\or August\or September\or October\or November\or December\fi
 }%
 \xdef\@received{Received\ \@recmonth\ \ignorespaces #3\unskip, 
  \ignorespaces #1\unskip}%
}
\def\@received{Received ??? ?? 202?}%
\def\accepted#1#2#3{\def\@temp@m{#2}\ifx \@temp@m\@empty\def\@temp@m{0}\fi
 \def\@acceptmonth{%
  \ifcase\@temp@m ???\or 
   January\or February\or March\or April\or May\or June\or
   July\or August\or September\or October\or November\or December\fi
 }%
 \xdef\@accepted{Accepted\ \@acceptmonth\ \ignorespaces #3\unskip, 
  \ignorespaces #1\unskip}}
\def\@accepted{Accepted ??? ?? 202?}

\newif\ifRAinfo@expand \RAinfo@expandfalse
\def\RA@info{\par
 \leavevmode\hfill
 \shortstack[r]{%
  \textbf{(\@received)}\\
  \textbf{(\@accepted)}%
 }%
 \global\RAinfo@expandtrue
}

\def\ps@footnombre{%
 \def\@evenhead{\@Ltop\hfil\@Rtop}%
 %\def\@oddhead{\@Ltop\hfil\@Rtop}%
 \let\@oddhead\@evenhead
 \def\@evenfoot{%
  \@Lbot\hfil\if@jscefinal\else{\nombre@font\thepage}\hfil\fi\@Rbot}%
 \let\@oddfoot\@evenfoot
 %\let\@mkboth\markboth
}

%% author 関係
\newtoks\@authorlist
\newcount\@authorcnt
\newcount\total@nr
\newcount\@alcnt
\newcount\chk@alcnt
\newbox\@tempboxc

\def\authorlist#1{%
 \if@english
  \let\authorentry\E@authorentry
 \fi
 \@authorlist={#1}\the\@authorlist\relax
}

\def\save@affi#1{#1}

\def\authorentry#1#2#3{%
 \def\tmp@an{#1}%
 \ifx\tmp@an\@empty
  \jsce@warning{Author's name is not specified}%
  \get@al{#3}%
 \else
  \@tempcnta\z@
  \advance \@authorcnt \@ne
  %% author label
  \get@al{#3}%
  \def\al@none{0}%
  %% author's name in Japanese
  \fmt@Jan{#1}% \the\@temptokena
  \expandafter\protected@xdef\csname @Jauthorname\number\@authorcnt\endcsname{%
   \@authorname\unskip\kern\z@\protect\save@affi{\plural@affi}%
  }%
  %% author's name in English for JPN
  \expandafter\protected@xdef\csname @Eauthorname\number\@authorcnt\endcsname{%
   %\@authorname
   #2\unskip\kern\z@\protect\save@affi{\plural@affi}%
  }%
  \global\total@nr=\@authorcnt
  \def\@tempcheck{}%
  \def\plural@affi{}%
 \fi
}

\def\E@authorentry#1#2{%
 \def\tmp@an{#1}%
 \ifx\tmp@an\@empty
  \jsce@warning{Author's name is not specified}%
  \get@al{#2}%
 \else
  \@tempcnta\z@
  \advance \@authorcnt \@ne
  %% author label
  \get@al{#2}%
  \def\al@none{0}%
  %% author's name in English
  \def\tr@name##1 ##2\@nil{##1 ##2}% omit \protect\uppercase
  \protected@edef\@authorname{\expandafter\tr@name #1\@nil\null}%
  \expandafter\protected@xdef\csname @Eauthorname\number\@authorcnt\endcsname{%
   \@authorname\unskip\kern\z@\protect\save@affi{\plural@affi}%
  }%
  \global\total@nr=\@authorcnt
  \def\plural@affi{}%
 \fi
}
\def\plural@affi{}

\def\name@expandafter#1#2{%
 \def\next{#1}%
 \edef\@tempa{#2}%
 \ifx\@tempa\@empty
  \jsce@warning{Author's name is empty}%
  \def\@tempa{\@empty}%
 \fi
 \expandafter\next\@tempa}
\def\chk@name#1{\name@expandafter\@chk@name{#1}\@nil}
\def\@chk@name#1#2\@nil{\def\get@oneword{#1}}

\def\fmt@Jan#1{%
 \@temptokena{#1}%
 %\setbox\@tempboxc\hbox{\spaceskip=100mm #1}%
 %\ifdim \wd\@tempboxc < 100mm
 % \jsce@warning{Author's name "#1" doesn't have a space}%
 % \def\@authorname{\the\@temptokena}%
 %\else
  \chk@name{\the\@temptokena}%
  \ifcat\get@oneword A% e.g. John SMITH
   \protected@xdef\@authorname{\hbox{#1}}%
  \else
   \protected@xdef\@authorname{\spaceskip=12\p@\hbox{#1}}%
  \fi
 %\fi
}

\def\get@al#1{%
 \def\al@none{none}\def\@tempaffi{#1}%
 \ifx\al@none\@tempaffi\else
  \@for\get@label:=#1\do{%
   \@ifundefined{chk@\get@label}{\global\advance \chk@alcnt \@ne
    \expandafter\gdef\csname chk@\get@label\endcsname{}%
   }{}%
   \expandafter\def\expandafter\save@al\expandafter{%
    \csname al@\get@label\endcsname}%
   \advance \@tempcnta \@ne
   \protected@xdef\plural@affi{\plural@affi
    \ifnum\@tempcnta=\@ne % ((
     $^{\save@al}$% )
    \else
     $^{,\save@al}$% )
    \fi
   }%
  }%
 \fi
}

\def\Jbreakauthorline#1{%
 \@for\@breakauthor:=#1\do{%
  \expandafter\gdef\csname J@breakauthorline\@breakauthor\endcsname{\par}%
 }%
 \@authorcnt\z@
 \loop\ifnum \@authorcnt < \total@nr
  \advance \@authorcnt \@ne
   \@ifundefined{J@breakauthorline\number\@authorcnt}%
    {\expandafter\gdef\csname J@breakauthorline\number\@authorcnt\endcsname
     {\relax}}%
    {}%
 \repeat
}

\def\@outputJauthorlist{%
 \@authorcnt\z@
 \loop\ifnum \@authorcnt < \total@nr
  \advance \@authorcnt \@ne
  \ifnum\@authorcnt=\total@nr
   \mbox{\csname @Jauthorname\number\@authorcnt\endcsname}%
  \else
   \mbox{\csname @Jauthorname\number\@authorcnt\endcsname%
    \hbox to 12\p@{\hss ・\hss}}%
  \fi
  \csname J@breakauthorline\number\@authorcnt\endcsname
 \repeat
}

\def\breakauthorline#1{%
 \@for\@breakauthor:=#1\do{%
  \expandafter\gdef\csname @breakauthorline\@breakauthor\endcsname{\par}%
 }%
 \@authorcnt\z@
 \loop\ifnum \@authorcnt < \total@nr
  \advance \@authorcnt \@ne
   \@ifundefined{@breakauthorline\number\@authorcnt}%
    {\expandafter\gdef\csname @breakauthorline\number\@authorcnt\endcsname
     {\relax}}%
    {\relax}%
 \repeat
}

\newcount\totalnumberm@ne
\def\@outputEauthorlist{%
 \@authorcnt\z@
 \totalnumberm@ne\total@nr \advance \totalnumberm@ne -\@ne
  \loop\ifnum \@authorcnt < \total@nr
   \advance \@authorcnt \@ne 
   \ifnum \@authorcnt < \totalnumberm@ne
    \mbox{\csname @Eauthorname\number\@authorcnt\endcsname, }%
    \csname @breakauthorline\number\@authorcnt\endcsname
   \else
    \ifnum \@authorcnt = \total@nr
     \mbox{\csname @Eauthorname\number\@authorcnt\endcsname}%
    \else
     \mbox{\csname @Eauthorname\number\@authorcnt\endcsname}%
     %%\ifnum \total@nr=\tw@\ \else, \fi
     \csname @breakauthorline\number\@authorcnt\endcsname
     \ and\ %
    \fi
   \fi
  \repeat
}

\newif\if@jsce@Caffi \@jsce@Caffifalse
\def\Caffiliate[#1]#2#3{%
 \@jsce@Caffitrue
 \affiliate[#1]{#2}{#3}%
}

\def\affiliate[#1]#2#3{% 
 \def\jipcode##1{〒\hskip0.125em ##1\hskip9\p@\ignorespaces}%
 \advance \@alcnt \@ne
 %\advance \chk@alcnt \@ne
 \@ifundefined{al@#1}%
  {\expandafter\xdef\csname al@#1\endcsname{\the\@alcnt}}{%
   \jsce@warning{Check the "#1" label, it is already assigned}%
  }%
 \def\tmp@affiliate{#3}%
 \protected@xdef\@affiliate{\@affiliate
  \protect\save@affi{$^{\csname al@#1\endcsname}$\kern\z@}%
  #2\\ 
  \ifx\tmp@affiliate\@empty\else
   E-mail: \protect\jsce@email{#3}%
   \ifnum\total@nr=\@ne\else
    \if@jsce@Caffi\ (Corresponding Author)\fi
   \fi
   \\
  \fi
  }%
 \@jsce@Caffifalse
}
\def\@affiliate{}

\newdimen\jscetitlemargin
\jscetitlemargin10mm
\newdimen\jsce@title@length
\newbox\@abstractbox
\newbox\@keywordbox

\def\abstract{\global\setbox\@abstractbox=\hbox\bgroup
 \jsce@title@length\textwidth
 \advance \jsce@title@length -2\jscetitlemargin
 \begin{minipage}[t]{\jsce@title@length}%
  \if@english
   \fontsize{10}{12\p@}\selectfont
   \parindent10\p@
  \else
   \small %\baselineskip12\p@
   \parindent9\p@
  \fi
  \ignorespaces}
\def\endabstract{\end{minipage}\egroup}

\def\keyword{\global\setbox\@keywordbox=\hbox\bgroup
 \jsce@title@length\textwidth
 \advance \jsce@title@length -2\jscetitlemargin
 \begin{minipage}[t]{\jsce@title@length}%
  \if@english
   \fontsize{10}{12\p@}\selectfont
  \else
   \normalsize\baselineskip12\p@
  \fi
  %\hskip10\p@
  \itshape
  %{\bfseries Key Words:\ }\ignorespaces
  \@hangfrom{\hskip10\p@\bfseries Key Words:\ }\ignorespaces
}
\def\endkeyword{\end{minipage}\egroup}

\newcommand{\maketitle}{\par
 \ifnum \chk@alcnt < \@alcnt
  \jsce@warning{Label of \string\affiliate\space is not assigned in \string\authorentry}%
 \fi
 \ifnum \chk@alcnt > \@alcnt
  \jsce@warning{Information of \string\affiliate\space is not assigned}%
 \fi
 %% 単著でも肩番号は付けることに
 %\ifnum\@alcnt=\@ne\let\save@affi\@gobble\fi
 %%
 \begingroup
  \renewcommand{\thefootnote}{\fnsymbol{footnote}}%
  \def\@makefnmark{\hbox{\ifydir $\m@th^{\@thefnmark}$
    \else\hbox{\yoko$\m@th^{\@thefnmark}$}\fi}}%
  \long\def\@makefntext##1{\parindent 1em\noindent
    \hb@xt@1.8em{\hss$\m@th^{\@thefnmark}$}##1}%
  %%
  \twocolumn[\@maketitle]%
  %\thispagestyle{FPjjsce}%
 \endgroup
 \setcounter{footnote}{0}%
 %\global\let\thanks\relax
 \global\let\maketitle\relax
 \global\let\@maketitle\relax
 %\global\let\p@thanks\relax
 %\global\let\@thanks\@empty
 %\global\let\@author\@empty
 %\global\let\@date\@empty
 \global\let\@jtitle\@empty
 \global\let\jtitle\relax
 \global\let\@jsubtitle\@empty
 \global\let\jsubtitle\relax
 %\global\let\@etitle\@empty
 %\global\let\etitle\relax
 \global\let\@esubtitle\@empty
 \global\let\esubtitle\relax
 \global\let\@title\@empty
 \global\let\title\relax
 \global\let\@subtitle\@empty
 \global\let\subtitle\relax
 %\global\let\author\relax
 %\global\let\date\relax
 %\global\let\and\relax
}

\def\jtitle#1{\gdef\@jtitle{#1}}
\def\@jtitle{}
\def\jsubtitle#1{\gdef\@jsubtitle{#1}}
\def\@jsubtitle{}

\def\jtitle@font{\bfseries\fontsize{20}{26\p@}\selectfont}
\let\jsubtitle@font\jtitle@font
\def\jauthor@font{\large}% 12pt baseline17pt

\newdimen\abovetitlesep \abovetitlesep\z@
\newdimen\aboveauthorsep \aboveauthorsep\z@
\newdimen\belowauthorsep \belowauthorsep\z@
\newdimen\belowaffiliatesep \belowaffiliatesep\z@

\def\etitle#1{\gdef\@etitle{#1}}% omit \uppercase
\def\@etitle{}
\def\esubtitle#1{\gdef\@esubtitle{#1}}% omit \uppercase
\def\@esubtitle{}
\if@english
 \let\title\etitle
 \let\subtitle\esubtitle
\fi

\def\etitle@font{\bfseries\fontsize{18}{20\p@}\selectfont}
\let\esubtitle@font\etitle@font
\def\eauthor@font{\large}% 12pt baseline17pt

\def\@maketitle{%
 %\jsce@title@length\textwidth
 %\advance \jsce@title@length -2\jscetitlemargin
 \jsce@title@length=\dimexpr \textwidth -2\jscetitlemargin\relax
 \if@english
 \setbox\@tempboxa\hbox{%
  \begin{minipage}{\jsce@title@length}
   \vskip10mm
   \vskip\abovetitlesep
   {\etitle@font\centering %% \removejfmglue
    \expandafter\inhibitglue
    \@etitle\par
   }%
   \ifx\@esubtitle\@empty
   \else
    \vskip3mm
    {\esubtitle@font\centering
     \expandafter\inhibitglue
     \@esubtitle\par
    }%
   \fi
   \vskip12mm %13.5mm
   \vskip\aboveauthorsep
   {\eauthor@font
    \centering
    \@outputEauthorlist\par
   }%
   \vskip3.5mm
   \vskip\belowauthorsep
   {\small\baselineskip10.5\p@
    \centering
    \@affiliate\par
   }%
   \vskip8mm
   \vskip\belowaffiliatesep
   \ifvoid\@abstractbox\else
    \noindent\box\@abstractbox\par
    \vskip4.7mm %4.5mm
   \fi
   \ifvoid\@keywordbox\else
    \noindent\box\@keywordbox\par
   \fi
  \end{minipage}%
 }%
 \else % 和文
 \setbox\@tempboxa\hbox{%
  \begin{minipage}{\jsce@title@length}
   \vskip10mm
   \vskip\abovetitlesep
   {\jtitle@font\centering %% \removejfmglue
    \leavevmode\expandafter\inhibitglue\expandafter\ignorespaces
    \@jtitle\par
   }%
   \ifx\@jsubtitle\@empty
   \else
    \vskip3mm
    {\jsubtitle@font\centering
     \leavevmode\expandafter\inhibitglue\expandafter\ignorespaces
     \@jsubtitle\par
    }%
   \fi
   \vskip13.5mm
   \vskip\aboveauthorsep
   {\jauthor@font
    \centering
    \@outputJauthorlist\par
   }%
   \vskip3.5mm
   \vskip\belowauthorsep
   {\small\baselineskip13\p@
    \centering
    \@affiliate\par
   }%
   \vskip8mm
   \vskip\belowaffiliatesep
   \ifvoid\@abstractbox\else
    \noindent\box\@abstractbox\par
    \vskip4.5mm
   \fi
   \ifvoid\@keywordbox\else
    \noindent\box\@keywordbox\par
   \fi
  \end{minipage}%
 }%
 \fi
 \@tempdima\ht\@tempboxa
 \advance \@tempdima \dp\@tempboxa
 \divide \@tempdima \Cvs
 \@tempcnta=\@tempdima
 \advance \@tempcnta \thr@@ %\tw@
 {\newpage\null
  \boxmaxdepth\z@
  \lineskiplimit\z@
  \lineskip\z@
  \parindent\z@
  \vbox to \@tempcnta\Cvs{%
   \leavevmode\hfil\box\@tempboxa
  \vss}%
 }\par
 %\vspace{\belowkeywordsep}%
}

%% makeEtitle
\if@english\else
\def\Etitle#1{\gdef\@Etitle{#1}}% omit \uppercase
\def\@Etitle{}
\def\Esubtitle#1{\gdef\@Esubtitle{#1}}% omit \uppercase
\def\@Esubtitle{}

\let\etitle\Etitle
\let\esubtitle\Esubtitle

\newdimen\jsce@Etitle@length
\newdimen\jsceEtitlemargin
\jsceEtitlemargin10mm

\newdimen\aboveEtitlesep \aboveEtitlesep\z@
\newdimen\aboveEauthorsep \aboveEauthorsep\z@
\newdimen\belowEauthorsep \belowEauthorsep\z@

\def\Etitle@font{\large}% 12pt line17pt
\let\Esubtitle@font\Etitle@font
\def\Eauthor@font{\large}% 12pt line17pt

\newbox\@Eabstractbox
\def\Eabstract{\global\setbox\@Eabstractbox=\hbox\bgroup
 %\jsce@Etitle@length\textwidth
 %\advance \jsce@Etitle@length -2\jsceEtitlemargin
 \jsce@Etitle@length=\dimexpr \textwidth -2\jsceEtitlemargin\relax
 \begin{minipage}[t]{\jsce@Etitle@length}%
  \normalsize\baselineskip12\p@
  \parindent10\p@
  \ignorespaces}
\def\endEabstract{\end{minipage}\egroup}

\newbox\@titleboxE
\newdimen\jsce@Etitle@height

\def\@makeEtitle{%
 %\jsce@Etitle@length\textwidth
 %\advance \jsce@Etitle@length -2\jsceEtitlemargin
 \jsce@Etitle@length=\dimexpr \textwidth -2\jsceEtitlemargin\relax
 \setbox\@titleboxE\hbox{%
  \begin{minipage}{\jsce@Etitle@length}
   \vskip5\p@ % 左右平行のときの補正
   \hrule \@height \z@
   \vskip10mm
   \vskip\aboveEtitlesep
   {\Etitle@font\centering
    \@Etitle\par
   }%
   \ifx\@Esubtitle\@empty\else
   \vskip1mm
   {\Esubtitle@font\centering
    \@Esubtitle\par
   }%
   \fi
   \vskip3.5mm
   \vskip\aboveEauthorsep
   {\Eauthor@font\centering
    \let\save@affi\@gobble
    \@outputEauthorlist\par
   }%
   \vskip4.5mm
   \vskip\belowEauthorsep
   \ifvoid\@Eabstractbox\else
    \noindent\box\@Eabstractbox\par
   \fi
   %\ifvoid\@keywordbox\else
   % \noindent\box\@keywordbox\par
   %\fi
  \end{minipage}%
 }%
 %%
 %\jsce@Etitle@height\ht\@titleboxE
 %\global\advance \jsce@Etitle@height \dp\@titleboxE
 \global\jsce@Etitle@height=\dimexpr \ht\@titleboxE + \dp\@titleboxE\relax
 \noindent\box\@titleboxE
}
\def\makeEtitle{%
 \hbox to \hsize{\hbox to \textwidth{\hss
  \@makeEtitle
 \hss}\hss}%
}
\fi

\setcounter{secnumdepth}{3}
%\newcounter{part}
\newcounter{section}
\newcounter{subsection}[section]
\newcounter{subsubsection}[subsection]
\newcounter{paragraph}[subsubsection]
\newcounter{subparagraph}[paragraph]
%\renewcommand{\thepart}{\@Roman\c@part}
\renewcommand{\thesection}{\@arabic\c@section}
\renewcommand{\thesubsection}{(\@arabic\c@subsection)}
\renewcommand{\thesubsubsection}{% (
 \@alph\c@subsubsection)}
\renewcommand{\theparagraph}{\@arabic\c@paragraph}
\renewcommand{\thesubparagraph}{\@arabic\c@subparagraph}

\def\@afterheading{%
 \global\@nobreaktrue
 \everypar{%
  \if@nobreak
   \global\@nobreakfalse
   \clubpenalty\z@ % \@M
    \if@afterindent
    \else
     {\setbox\z@=\lastbox}%
    \fi
  \else
   \clubpenalty\@clubpenalty
   \everypar{}%
  \fi}%
}

%% \@startsection{NAME}{LEVEL}{INDENT}{BEFORESKIP}{AFTERSKIP}{STYLE}
\def\@startsection#1#2#3#4#5#6{%
 \if@noskipsec \leavevmode \fi
 \par \@tempskipa #4\relax
 \@afterindenttrue
 \ifdim \@tempskipa <\z@ \@tempskipa -\@tempskipa \@afterindentfalse\fi
  \if@nobreak
   \everypar{}%
  \else
   %\addpenalty\@secpenalty
   \if@english
    \addvspace\@tempskipa
   \else
    \ifdim\@tempskipa>\z@
     \ifnum#2=\@ne
      \vskip-\prevdepth \prevdepth\z@ \vskip\Cvs
      \advance\@tempskipa-3\Cvs
      \vspace{2\Cvs}%
      \vspace*{\@tempskipa}%
     \else
      \ifnum#2=\tw@
       \vskip-\prevdepth \prevdepth\z@ \vskip\Cvs
       \advance\@tempskipa-2\Cvs
       \vspace{\Cvs}
       \vspace*{\@tempskipa}
      \else
       \addvspace\@tempskipa
      \fi
     \fi
    \fi
   \fi
  \fi
 \@ifstar{\@ssect{#3}{#4}{#5}{#6}}{\@dblarg{\@sect{#1}{#2}{#3}{#4}{#5}{#6}}}}

\if@english
 \def\sectionnum@font{\bfseries}% \fontsize{12\p@}{\z@}\selectfont}
 \def\subsectionnum@font{\bfseries}% \fontsize{10\p@}{\z@}\selectfont}
 \def\@seccntformat#1{\csname the#1\endcsname\hskip5\p@}
\else
 \def\sectionnum@font{\fontsize{11}{1\Cvs}\selectfont\sffamily}% 
 \def\subsectionnum@font{\sffamily}
 \def\@seccntformat#1{\csname the#1\endcsname\hskip10\p@}
\fi
\def\dotafter@section{{.}}

%\newif\if@aftersec\@aftersecfalse

%% \@sect{NAME}{LEVEL}{INDENT}{BEFORESKIP}{AFTERSKIP}{STYLE}[ARG1]{ARG2}
%% \ifdim \@tempskipa>\z@ --> \ifdim \@tempskipa<\z@
\def\@sect#1#2#3#4#5#6[#7]#8{%
 %\global\@aftersecfalse
 \ifnum #2>\c@secnumdepth
  \let\@svsec\@empty
 \else
  \refstepcounter{#1}%
  \ifnum#2=\@ne
   \protected@edef\@svsec{%
    \csname #1num@font\endcsname\csname the#1\endcsname
    \csname dotafter@#1\endcsname\if@english\hskip5.25\p@\else\hskip10.5\p@\fi}%
   %\global\@aftersec true
  \else
   \ifnum#2=\tw@
    \protected@edef\@svsec{%
     \csname #1num@font\endcsname\csname the#1\endcsname
     \if@english\hskip5\p@\else\hskip10\p@\fi}%
   \else
    \protected@edef\@svsec{\@seccntformat{#1}\relax}%
   \fi
  \fi
 \fi
  \@tempskipa #5\relax
  \ifdim \@tempskipa<\z@
   \def\@svsechd{%
     #6{\hskip #3\relax
     \@svsec #8}%
    %\csname #1mark\endcsname{#7}%
    %\addcontentsline{toc}{#1}{%
    % \ifnum #2>\c@secnumdepth \else
    %   \protect\numberline{\csname the#1\endcsname}%
    % \fi
    % #7}%
   }%
  \else
   \begingroup
    #6{%
      \@hangfrom{\hskip #3\relax\@svsec}%
       \interlinepenalty \@M #8\@@par
      }%
   \endgroup
   %\csname #1mark\endcsname{#7}%
   %\addcontentsline{toc}{#1}{%
   % \ifnum #2>\c@secnumdepth \else
   %  \protect\numberline{\csname the#1\endcsname}%
   % \fi
   % #7}%
  \fi
  \@xsect{#5}}

%% \@ssect{INDENT}{BEFORESKIP}{AFTERSKIP}{STYLE}{ARG} ==
%% \ifdim \@tempskipa>\z@ --> \ifdim \@tempskipa<\z@
\def\@ssect#1#2#3#4#5{%
 \@tempskipa #3\relax
 \ifdim \@tempskipa<\z@
  \def\@svsechd{#4{\hskip #1\relax #5}}%
 \else
  \begingroup
    #4{%
     \@tempskipa #2\relax
     \if@appendix
      \ifdim\@tempskipa=2\Cvs % section* after app
       \@hangfrom{\appendixname\hskip11\p@}%
       \interlinepenalty\@M #5\@@par
      \else
       \@hangfrom{\hskip #1}%
       \interlinepenalty\@M #5\@@par
      \fi
     \else
      \@hangfrom{\hskip #1}%
      \interlinepenalty\@M #5\@@par
     \fi
      }%
  \endgroup
 \fi
 \@xsect{#3}}

%% \ifdim \@tempskipa>\z@ --> \ifdim \@tempskipa<\z@
\def\@xsect#1{%
  \@tempskipa #1\relax
  \ifdim \@tempskipa<\z@
    \@nobreakfalse
    \global\@noskipsectrue
    \everypar{%
      \if@noskipsec
        \global\@noskipsecfalse
       {\setbox\z@\lastbox}%
        \clubpenalty\@M
        \begingroup \@svsechd \endgroup
        \unskip
        \@tempskipa #1\relax
        \hskip -\@tempskipa
        \pagebreak[1]% 2-->1
      \else
        \clubpenalty \@clubpenalty
        \everypar{}%
      \fi}%
  \else
    \par \nobreak
    \vskip \@tempskipa
    \@afterheading
  \fi
  \ignorespaces}

\if@english
\newcommand{\section}{\@startsection{section}{1}{\z@}%
   {2\Cvs}% \@plus.5\Cvs \@minus.2\Cvs
   {1\Cvs}% \@plus.5\Cvs \@minus.2\Cvs
   {\fontsize{12}{1\Cvs}\selectfont\bfseries}}
\newcommand{\subsection}{\@startsection{subsection}{2}{\z@}%
   {1\Cvs}% \@plus.5\Cvs \@minus.2\Cvs
   {\z@}%
   {\normalfont\normalsize\bfseries}}% 11pt
\newcommand{\subsubsection}{\@startsection{subsubsection}{3}{\z@}%
   {\z@}%
   {\z@}%
   {\normalfont\normalsize\bfseries}}% 11pt
\else
\newcommand{\section}{\@startsection{section}{1}{\z@}%
   {2\Cvs}% \@plus.5\Cvs \@minus.2\Cvs
   {1\Cvs}% \@plus.5\Cvs \@minus.2\Cvs
   {\sffamily\gtfamily\fontsize{11}{1\Cvs}\selectfont}}
\newcommand{\subsection}{\@startsection{subsection}{2}{\z@}%
   {1\Cvs}% \@plus.5\Cvs \@minus.2\Cvs
   {\z@}% \@plus.3\Cvs
   {\sffamily\gtfamily\normalsize}}
\newcommand{\subsubsection}{\@startsection{subsubsection}{3}{\z@}%
   {\z@}% \@plus.3\Cvs
   {\z@}% \@plus.3\Cvs
   {\sffamily\gtfamily\normalsize}}
\fi
\newcommand{\paragraph}{\@startsection{paragraph}{4}{\z@}%
   {1\Cvs \@plus.5\Cvs \@minus.2\Cvs}%
   {-10\p@}%
   {\normalfont\normalsize\bfseries}}
\newcommand{\subparagraph}{\@startsection{subparagraph}{5}{\z@}%
   {1\Cvs \@plus.5\Cvs \@minus.2\Cvs}%
   {-10\p@}%
   {\normalfont\normalsize\bfseries}}

\newif\if@appendix \@appendixfalse
\newcommand{\appendix}{\par
 \@appendixtrue
 \setcounter{section}{0}%
 \setcounter{subsection}{0}%
 \def\dotafter@section{}%
 \renewcommand{\thesection}{\appendixname~\@Alph\c@section}%
}

\if@twocolumn
  \setlength\leftmargini {20\p@}
\else
  \setlength\leftmargini {20\p@}
\fi
\setlength\leftmarginii  {20\p@}
\setlength\leftmarginiii {20\p@}
\setlength\leftmarginiv  {20\p@}
\if@twocolumn
  \setlength\leftmarginv {10\p@}
  \setlength\leftmarginvi{10\p@}
\else
  \setlength\leftmarginv {10\p@}
  \setlength\leftmarginvi{10\p@}
\fi
\setlength  \labelsep  {5\p@}
\setlength  \labelwidth{\leftmargini}
\addtolength\labelwidth{-\labelsep}
\@beginparpenalty\z@ % -\@lowpenalty
\@endparpenalty\z@ %   -\@lowpenalty
\@itempenalty\z@ %     -\@lowpenalty

\renewcommand{\theenumi}{\@arabic\c@enumi}
\renewcommand{\theenumii}{\@alph\c@enumii}
\renewcommand{\theenumiii}{\@roman\c@enumiii}
\renewcommand{\theenumiv}{\@Alph\c@enumiv}
\newcommand{\labelenumi}{\theenumi.}
\newcommand{\labelenumii}{(\theenumii)}
\newcommand{\labelenumiii}{\theenumiii.}
\newcommand{\labelenumiv}{\theenumiv.}
\renewcommand{\p@enumii}{\theenumi}
\renewcommand{\p@enumiii}{\theenumi(\theenumii)}
\renewcommand{\p@enumiv}{\p@enumiii\theenumiii}

\renewenvironment{enumerate}
  {\ifnum \@enumdepth >3\relax\@toodeep\else
   \advance\@enumdepth\@ne
   \edef\@enumctr{enum\romannumeral\the\@enumdepth}%
   \list{\csname label\@enumctr\endcsname}{% 
   %\expandafter \list \csname label\@enumctr\endcsname{%
     \ifnum \@listdepth=\@ne
      \topsep.5\baselineskip
     \else
      \topsep\z@
     \fi
     \parsep\z@\partopsep\z@\itemsep\z@
     \ifnum\@enumdepth=\thr@@
      \settowidth{\labelwidth}{iii.}%
     \else
      \settowidth{\labelwidth}{\csname label\@enumctr\endcsname}%
     \fi
     \labelsep5\p@
     \leftmargin\labelwidth
     \advance\leftmargin \labelsep
     \advance\leftmargin 10\p@
     \listparindent10\p@
     \clubpenalty\z@
     \widowpenalty\z@
     \@itempenalty\z@
     \usecounter{\@enumctr}%
     \def\makelabel##1{\hss\llap{##1}}}%
   \fi}{\endlist}

\newcommand{\labelitemi}{\leavevmode\labelitemfont
 \if@english\else\raise.5\p@\fi\hbox to 10\p@{\hss \textbullet\hss}}
\newcommand{\labelitemii}{\leavevmode\labelitemfont
 \if@english\else\raise1.5\p@\fi\hbox to 10\p@{\hss \textendash\hss}}
\newcommand{\labelitemiii}{\leavevmode\labelitemfont
 \if@english\else\raise1.25\p@\fi\hbox to 10\p@{\hss \textasteriskcentered\hss}}
\newcommand{\labelitemiv}{\leavevmode\labelitemfont
 \if@english\else\hbox to 10\p@\fi{\hss ・\hss}}
\newcommand\labelitemfont{\normalfont}

\renewenvironment{itemize}
  {\ifnum \@itemdepth >3\relax\@toodeep\else
   \advance\@itemdepth\@ne
   \edef\@itemitem{labelitem\romannumeral\the\@itemdepth}%
   \expandafter
   \list{\csname \@itemitem\endcsname}{% 
   %\expandafter \list \csname \@itemitem\endcsname{%
     \ifnum \@listdepth=\@ne
      \topsep.5\baselineskip
     \else
      \topsep\z@
     \fi
     \parsep\z@\partopsep\z@\itemsep\z@
     \labelwidth10\p@
     \labelsep\z@
     \leftmargin10\p@
     \advance\leftmargin 10\p@
     \listparindent10\p@
     \clubpenalty\z@
     \widowpenalty\z@
     \@itempenalty\z@
     \def\makelabel##1{\hss\llap{##1}}}%
   \fi}{\endlist}

\newenvironment{description}
  {\list{}{\labelwidth\z@ \itemindent-\leftmargin
   \iftdir
     \leftmargin\leftskip \advance\leftmargin3\Cwd
     \rightmargin\rightskip
     \labelsep=10\p@ \itemsep\z@
     \listparindent\z@ \topskip\z@ \parskip\z@ \partopsep\z@
   \else
    \ifnum \@listdepth=\@ne
     \topsep.5\baselineskip
    \else
     \topsep\z@
    \fi
   \fi
   \let\makelabel\descriptionlabel}}{\endlist}

\newcommand{\descriptionlabel}[1]{%
   \hspace\labelsep\normalfont\bfseries #1}
\newenvironment{verse}
  {\let\\\@centercr
   \list{}{\itemsep\z@ \itemindent -1.5em%
           \listparindent\itemindent
           \rightmargin\leftmargin \advance\leftmargin 1.5em}%
           \item\relax}{\endlist}

\newenvironment{quotation}
  {\list{}{%
   \ifnum \@listdepth=\@ne
    \topsep.5\baselineskip
   \else
    \topsep\z@
   \fi
   \parsep\z@\partopsep\z@\itemsep\z@
   \listparindent10\p@
   \itemindent\listparindent
   \rightmargin\leftmargin
   }%
   \item\relax}{\endlist}
\newenvironment{quote}
  {\list{}{%
   \ifnum \@listdepth=\@ne
    \topsep.5\baselineskip
   \else
    \topsep\z@
   \fi
   \parsep\z@\partopsep\z@\itemsep\z@
   \rightmargin\leftmargin}%
   \item\relax}{\endlist}

\def\@verbatim{%
  \topsep\z@\parsep\z@\partopsep\z@\itemsep\z@
  \trivlist \item\relax
  \if@minipage\else\vskip2\parskip\fi
  \leftskip\@totalleftmargin\rightskip\z@skip
  \parindent\z@\parfillskip\@flushglue\parskip\z@skip
  \@@par
  \language\l@nohyphenation
  \@tempswafalse
  \def\par{%
    \if@tempswa
      \leavevmode \null \@@par\penalty\interlinepenalty
    \else
      \@tempswatrue
      \ifhmode\@@par\penalty\interlinepenalty\fi
    \fi}%
  \let\do\@makeother \dospecials
  \obeylines \verbatim@font \@noligs
  \everypar \expandafter{\the\everypar \unpenalty}%
}

\newcounter{figure}
\renewcommand{\thefigure}{\@arabic\c@figure}
\def\fps@figure{tbp}
\def\ftype@figure{1}
\def\ext@figure{lof}
\def\fnum@figure{\figurename\thefigure}
\newenvironment{figure}
               {\abovecaptionskip.25\baselineskip\belowcaptionskip\z@
                \let\center\Center\let\endcenter\endCenter\@float{figure}}
               {\end@float}
\newenvironment{figure*}
               {\@dblfloat{figure}}
               {\end@dblfloat}

\newcounter{table}
\renewcommand{\thetable}{\@arabic\c@table}
\def\fps@table{tbp}
\def\ftype@table{2}
\def\ext@table{lot}
\def\fnum@table{\tablename\thetable}
\newenvironment{table}
               {\abovecaptionskip\z@\belowcaptionskip.5\baselineskip
                \let\center\Center\let\endcenter\endCenter\@float{table}}
               {\end@float}
\newenvironment{table*}
               {\@dblfloat{table}}
               {\end@dblfloat}

\newlength\abovecaptionskip
\newlength\belowcaptionskip

\def\Center{\topsep\z@\parsep\z@\partopsep\z@\itemsep\z@
 \trivlist \centering\item\relax}
\def\endCenter{\endtrivlist}

\long\def\@caption#1[#2]#3{\par
 %\addcontentsline{\csname ext@#1\endcsname}{#1}%
 % {\protect\numberline{\csname the#1\endcsname}{\ignorespaces #2}}%
 \begingroup
  \@parboxrestore
  \if@minipage
   \@setminipage
  \fi
  \@makecaption{\csname fnum@#1\endcsname}{\ignorespaces #3}\par
 \endgroup}

\newbox\@tempboxb
\newdimen\capwidth \capwidth\hsize

\long\def\@makecaption#1#2{%
 \if@english
  \small\baselineskip12\p@
  \let\@floatnamefont\bfseries
 \else
  \small\baselineskip15\p@
  \def\@floatnamefont{\sffamily\gtfamily}%
 \fi
 \vskip\abovecaptionskip
 \@tempdima9\p@
 \setbox\@tempboxa\hbox{{\@floatnamefont #1}\hskip\@tempdima #2}%
 \setbox\@tempboxb\hbox{{\@floatnamefont #1}\hskip\@tempdima}%
 \ifdim \wd\@tempboxa > \hsize
  \hangindent\wd\@tempboxb
  {\@floatnamefont #1}\hskip9\p@ #2\par
 \else
  \hbox to \hsize{\hss\box\@tempboxa\hss}\par
 \fi
 \vskip\belowcaptionskip
}

\setlength\arraycolsep{5\p@}
\setlength\tabcolsep{6\p@}
\setlength\arrayrulewidth{.4\p@}
\setlength\doublerulesep{2\p@}
\setlength\tabbingsep{\labelsep}
\skip\@mpfootins = \skip\footins
\setlength\fboxsep{3\p@}
\setlength\fboxrule{.4\p@}
\renewcommand{\theequation}{\@arabic\c@equation}

%\DeclareRobustCommand{\mathmc}{%
%    \@latex@error{Command \noexpand\mathmc invalid with\space
%       `disablejfam' class option.}\@eha
%  }
%  \DeclareRobustCommand{\mathgt}{%
%    \@latex@error{Command \noexpand\mathgt invalid with\space
%       `disablejfam' class option.}\@eha
%}

\ifx\directlua\@undefined
\if@enablejfam
  \if@compatibility\else
    \DeclareSymbolFont{mincho}{\kenc@JYn}{mc}{m}{n}
    \DeclareSymbolFontAlphabet{\mathmc}{mincho}
    \SetSymbolFont{mincho}{bold}{\kenc@JYn}{gt}{m}{n}
    \jfam\symmincho
    \DeclareMathAlphabet{\mathgt}{\kenc@JYn}{gt}{m}{n}
  \fi
  \if@mathrmmc
    \AtBeginDocument{%
    \reDeclareMathAlphabet{\mathrm}{\mathrm}{\mathmc}
    \reDeclareMathAlphabet{\mathbf}{\mathbf}{\mathgt}
  }%
  \fi
\else
  \DeclareRobustCommand{\mathmc}{%
    \@latex@error{Command \noexpand\mathmc invalid with\space
       `disablejfam' class option.}\@eha
  }
  \DeclareRobustCommand{\mathgt}{%
    \@latex@error{Command \noexpand\mathgt invalid with\space
       `disablejfam' class option.}\@eha
  }
\fi
\fi

\DeclareOldFontCommand{\mc}{\normalfont\mcfamily}{\mathmc}
\DeclareOldFontCommand{\gt}{\normalfont\gtfamily}{\mathgt}
\DeclareOldFontCommand{\rm}{\normalfont\rmfamily}{\mathrm}
\DeclareOldFontCommand{\sf}{\normalfont\sffamily}{\mathsf}
\DeclareOldFontCommand{\tt}{\normalfont\ttfamily}{\mathtt}
\DeclareOldFontCommand{\bf}{\normalfont\bfseries}{\mathbf}
\DeclareOldFontCommand{\it}{\normalfont\itshape}{\mathit}
\DeclareOldFontCommand{\sl}{\normalfont\slshape}{\@nomath\sl}
\DeclareOldFontCommand{\sc}{\normalfont\scshape}{\@nomath\sc}
\DeclareRobustCommand*{\cal}{\@fontswitch\relax\mathcal}
\DeclareRobustCommand*{\mit}{\@fontswitch\relax\mathnormal}

\def\Acknowledgment{%
 \vskip1\Cvs
 \noindent
 \if@english
  {\bfseries ACKNOWLEDGMENT:}\ 
 \else
  {\bfseries 謝辞：}%
 \fi
 \ignorespaces
}

\newdimen\bibindent
\setlength\bibindent{1.5em}
\newcommand{\newblock}{\hskip .11em\@plus.33em\@minus.07em}
\newenvironment{thebibliography}[1]
 {%
  %% endnotes before reference
  \@ifundefined{theendnotes}{}{%
   \begingroup
    \IfFileExists{\jobname.ent}{%
     \theendnotes\par
    }{}%
   \endgroup
  }%
  %%
  \vskip\baselineskip
  \small
  \if@english
   \baselineskip3.75mm
   \noindent
   {\fontsize{10}{3.75mm}\selectfont\bfseries \refname}\par
  \else
   \baselineskip4.25mm
   \noindent
   {\refname}\par
  \fi
  \nopagebreak
   \list{\@biblabel{\@arabic\c@enumiv}}%
        {\settowidth\labelwidth{\@biblabel{#1}}%
         \topsep\z@\parsep\z@\partopsep\z@\itemsep\z@
         \leftmargin\labelwidth
         \advance\leftmargin\labelsep
         \@openbib@code
         \usecounter{enumiv}%
         \let\p@enumiv\@empty
         \renewcommand\theenumiv{\@arabic\c@enumiv}}%
   \sloppy
   \clubpenalty\z@ %4000
   \@clubpenalty\clubpenalty
   \widowpenalty\z@ %4000
   \sfcode`\.\@m}
  {\def\@noitemerr
    {\@latex@warning{Empty `thebibliography' environment}}%
   \endlist
   {\small
    \vskip\baselineskip
    \RA@info}\par
  }
\let\@openbib@code\@empty

\def\@biblabel#1{%(
 #1)}

%\def\@cite#1#2{[{#1\if@tempswa , #2\fi}]}
\def\@cite#1#2{%(
 \unskip\kern\z@
 \mbox{$\m@th^{\hbox{\scriptsize {#1\if@tempswa , #2\fi})}}$}%
}

\renewcommand{\footnoterule}{%
  \kern-3\p@
  \hrule\@width.4\columnwidth
  \kern2.6\p@}

\def\@makefnmark{\smash{\kern\z@
 \hbox{\@textsuperscript{\normalfont \@thefnmark}}\kern\z@}}
\newcommand\@makefntext[1]{\parindent9\p@
  \noindent\hbox to 9\p@{\hss\@makefnmark}#1}

%% 旧 jsce.cls では改変なし
\def\@begintheorem#1#2{%
 \topsep.5\Cvs
 \parsep\z@\partopsep\z@\itemsep\z@
 \labelsep10\p@
 \trivlist
  \item[\hskip \labelsep{\bfseries #1\ #2}]%
  \if@english
   \itshape
  \fi
}%
\def\@opargbegintheorem#1#2#3{%
 \topsep.5\Cvs
 \parsep\z@\partopsep\z@\itemsep\z@
 \labelsep10\p@
 \trivlist
 \if@english
  \item[\hskip \labelsep{\bfseries #1\ #2\ (#3)}]\itshape
 \else
  \item[\hskip \labelsep{\bfseries #1\ #2（#3）\inhibitglue}]%
 \fi
}
\def\@endtheorem{\endtrivlist}

\newif\if西暦 \西暦true
\def\西暦{\西暦true}
\def\和暦{\西暦false}
\newcount\heisei \heisei\year \advance\heisei-1988\relax
\def\pltx@today@year@#1{%
  \ifnum\numexpr\year-#1=1 元\else
    \ifnum1=\iftdir\ifmdir0\else1\fi\else0\fi
      \kansuji\number\numexpr\year-#1\relax
    \else
      \number\numexpr\year-#1\relax\nobreak
    \fi
  \fi 年
}
\def\pltx@today@year{%
  \ifnum\numexpr\year*10000+\month*100+\day<19890108
    昭和\pltx@today@year@{1925}%
  \else\ifnum\numexpr\year*10000+\month*100+\day<20190501
    平成\pltx@today@year@{1988}%
  \else
    令和\pltx@today@year@{2018}%
  \fi\fi}
\def\today{{%
  \if西暦
    \ifnum1=\iftdir\ifmdir0\else1\fi\else0\fi\kansuji\number\year
    \else\number\year\nobreak\fi 年
  \else
    \pltx@today@year
  \fi
  \ifnum1=\iftdir\ifmdir0\else1\fi\else0\fi
    \kansuji\number\month 月
    \kansuji\number\day 日
  \else
    \number\month\nobreak 月
    \number\day\nobreak 日
  \fi}}

%\newcommand{\contentsname}{目 次}
%\newcommand{\listfigurename}{図 目 次}
%\newcommand{\listtablename}{表 目 次}
%\newcommand{\indexname}{索 引}
%\newcommand{\abstractname}{概要}
\newcommand{\refname}{\textbf{REFERENCES}}
\if@english
 \newcommand{\figurename}{Fig.\,}
 \newcommand{\tablename}{Table~}
 \newcommand{\appendixname}{APPENDIX}
\else
 \newcommand{\figurename}{図{\normalfont\raise.325ex\hbox{-}}}%\llap{─}
 \newcommand{\tablename}{表{\normalfont\raise.325ex\hbox{-}}}
 \newcommand{\appendixname}{付録}
\fi

\ifx\directlua\@undefined
\postbreakpenalty`（=10000
\prebreakpenalty`）=10000
\postbreakpenalty`［=10000
\prebreakpenalty`］=10000
\postbreakpenalty`〈=10000
\prebreakpenalty`〉=10000
\prebreakpenalty`"=10000
\prebreakpenalty`℃=10000
\prebreakpenalty`　=10000
\prebreakpenalty`・=10000
\prebreakpenalty`〜=10000
\prebreakpenalty`ー=10000
\prebreakpenalty`？=10000
\prebreakpenalty`！=10000
\if@enable@uptex
 \postbreakpenalty16=10000
\else
 \postbreakpenalty"5C=10000
\fi
\postbreakpenalty`【=10000
\prebreakpenalty`】=10000
\postbreakpenalty`〔=10000
\prebreakpenalty`〕=10000
\postbreakpenalty`『=10000
\prebreakpenalty`』=10000
\inhibitxspcode`〒=2
\inhibitxspcode`！=1
\else
\ltjsetparameter{prebreakpenalty={`，,10000}}
\ltjsetparameter{prebreakpenalty={`．,10000}}
\ltjsetparameter{prebreakpenalty={`、,10000}}
\ltjsetparameter{prebreakpenalty={`。,10000}}
\ltjsetparameter{prebreakpenalty={`）,10000}}
\ltjsetparameter{prebreakpenalty={`」,10000}}
\ltjsetparameter{prebreakpenalty={`』,10000}}
\ltjsetparameter{prebreakpenalty={`］,10000}}
\ltjsetparameter{prebreakpenalty={`〉,10000}}
\ltjsetparameter{prebreakpenalty={`〕,10000}}
\ltjsetparameter{prebreakpenalty={`】,10000}}
\ltjsetparameter{prebreakpenalty={`〜,10000}}
\ltjsetparameter{prebreakpenalty={`…,10000}}
\ltjsetparameter{prebreakpenalty={`・,10000}}
\ltjsetparameter{prebreakpenalty={`ー,10000}}
\ltjsetparameter{prebreakpenalty={`！,10000}}
\ltjsetparameter{prebreakpenalty={`？,10000}}
\ltjsetparameter{postbreakpenalty={`（,10000}}
\ltjsetparameter{postbreakpenalty={`「,10000}}
\ltjsetparameter{postbreakpenalty={`『,10000}}
\ltjsetparameter{postbreakpenalty={`［,10000}}
\ltjsetparameter{postbreakpenalty={`〈,10000}}
\ltjsetparameter{postbreakpenalty={`〔,10000}}
\ltjsetparameter{postbreakpenalty={`【,10000}}
\ltjsetparameter{jaxspmode={`\{,1}}
\ltjsetparameter{jaxspmode={`\},2}}
\ltjsetparameter{jaxspmode={`!,2}}
\ltjsetparameter{jaxspmode={`〒,1}}
\ltjsetparameter{alxspmode={`+,3}}
\ltjsetparameter{alxspmode={`\%,3}}
\ltjsetparameter{jcharwidowpenalty=500}
\fi

\def\TinyMathSkip{%
 \abovedisplayskip .15\Cvs \@plus .075\Cvs \@minus .06\Cvs
 \belowdisplayshortskip .2\Cvs \@plus .1\Cvs \@minus .02\Cvs
 \belowdisplayskip \abovedisplayskip
}
\def\SmallMathSkip{%
 \abovedisplayskip .35\Cvs \@plus .175\Cvs \@minus .105\Cvs
 \belowdisplayshortskip .25\Cvs \@plus .125\Cvs \@minus .075\Cvs
 \belowdisplayskip \abovedisplayskip
}
\def\NormalMathSkip{%
 \abovedisplayskip.5\Cvs \@plus.25\Cvs \@minus.15\Cvs
 %\abovedisplayshortskip\z@ \@plus.15\Cvs
 \belowdisplayshortskip.3\Cvs \@plus.15\Cvs \@minus.1\Cvs
 \belowdisplayskip \abovedisplayskip
}

\def\sloppy{\tolerance9999\hbadness9999\hfuzz.5\p@ \vfuzz.5\p@}

\hbadness4000
\vbadness10001
\tolerance4000\pretolerance\m@ne
\clubpenalty\z@
\widowpenalty\z@

\AtBeginDocument{%
 %%
 \def\qhv@scale{1.05}%
 %% 
 \if@tinymathskip\TinyMathSkip\fi
 \if@smallmathskip\SmallMathSkip\fi
 \displaywidowpenalty\z@
 \interdisplaylinepenalty\z@
 \predisplaypenalty\z@
 \postdisplaypenalty\z@
 %% don't use geometry.sty
 \@ifpackageloaded{geometry}{%
  \jsce@warning{Don't use package "geometry"}%
  \def\geometry{Don't use package ``geometry.sty''.}\geometry}{}%
 %% url
 \@ifpackageloaded{url}{%
  \DeclareUrlCommand\jsce@email{\urlstyle{rm}}%
 }{}%
 %% amsthm
 \@ifpackageloaded{amsthm}{%
  %% \thm@preskip=\topsep \thm@postskip=\thm@preskip と定義済み
  %% [] の中のパーレンを全角に/後ろのピリを削除/head の後ろを一字空きに
  \def\@thm#1#2#3{%
    \ifhmode\unskip\unskip\par\fi
    \normalfont
    \trivlist
    \let\thmheadnl\relax
    \let\thm@swap\@gobble
    %\thm@notefont{\fontseries\mddefault\upshape}%
    \thm@notefont{\bfseries}%
    \thm@headpunct{}% add period after heading
    %\thm@headsep 5\p@ plus\p@ minus\p@\relax
    \thm@headsep 10\p@ \@plus 1.5\p@ \@minus 2.5\p@\relax
    %\thm@space@setup
    \thm@preskip=.5\Cvs
    \thm@postskip=\thm@preskip
    #1% style overrides
    \@topsep \thm@preskip               % used by thm head
    \@topsepadd \thm@postskip           % used by \@endparenv
    \def\@tempa{#2}\ifx\@empty\@tempa
      \def\@tempa{\@oparg{\@begintheorem{#3}{}}[]}%
    \else
      \refstepcounter{#2}%
      \def\@tempa{\@oparg{\@begintheorem{#3}{\csname the#2\endcsname}}[]}%
    \fi
    \@tempa
  }%
  %\def\@endtheorem{\endtrivlist \@doendpe}% \@endpefalse void
  \def\th@plain{% style=plain
   \if@english
    \itshape % body font
   \fi
  }%
  \def\th@remark{% style=remark
   \thm@headfont{\bfseries}%
   \normalfont % body font
   %\thm@preskip\topsep \divide\thm@preskip\tw@
   %\thm@postskip\thm@preskip
  }%
  \def\thmhead@plain#1#2#3{%
    \thmname{#1}\thmnumber{\@ifnotempty{#1}{ }\@upn{#2}}%
    \thmnote{{\the\thm@notefont
     \if@english
      \ (#3)%
     \else
      （#3）\inhibitglue
     \fi
    }}}%
  \let\thmhead\thmhead@plain
  %% \swapnumbers
  \def\swappedhead#1#2#3{%
    \thmnumber{#2}%
    \thmname{\@ifnotempty{#2}{~}#1}%
    \thmnote{ {\the\thm@notefont （#3）\inhibitglue}}}%
  %% proof
  \if@english
   \def\proofname{\textbf{Proof}}%
  \else
   \def\proofname{\textbf{証明}}%
  \fi
  \renewenvironment{proof}[1][\proofname]{\par
    \pushQED{\qed}%
    \normalfont
    \labelsep10\p@
    \trivlist
    \item[\hskip\labelsep
          \if@english\itshape\fi
      \textbf{#1\inhibitglue}\@addpunct{}]\ignorespaces
  }{%
    \popQED
    \endtrivlist\@endpefalse
  }%
 }{}%
 %% cite.sty +Cite
 \@ifpackageloaded{cite}{%
  %% Superscript cite
  %\renewcommand\citeleft{}% -> superscript のときは無効
  %\renewcommand\citeright{)}% -> superscript のときは無効
  \renewcommand\citeform[1]{#1)}%
  \renewcommand\citedash{--}%
  %\def\@citess#1{\mbox{$\m@th^{\hbox{\OverciteFont{#1}}}$}}%
  \if@english\else
   \def\@citess#1{\kern\z@
    \mbox{$\m@th^{\hbox{\OverciteFont{#1}}}$}}%
  \fi
  \DeclareRobustCommand{\Cite}{%
   \renewcommand\citeleft{}%
   \renewcommand\citeright{}%
   \@ifnextchar[%]
    {\@tempswatrue\@citex}{\@tempswafalse\@citex[]}}%
 }{}%
 %% endnotes.sty
 \@ifpackageloaded{endnotes}{%
  \if@english\else
   \def\endnote{\inhibitglue\unskip\kern\z@
      \@ifnextchar[%]
        \@xendnote{\stepcounter{endnote}%
        \protected@xdef\@theenmark{\theendnote}%
        \@endnotemark\@endnotetext}}%
  \fi
  \let\footnote\endnote
  \if@english
   \def\@makeenmark{%
    \smash{\kern\z@\hbox{\@textsuperscript{\normalfont %(
     $\ast$\@theenmark)}}\kern\z@}}%
   \def\enoteformat{% \rightskip\z@\leftskip\z@ %(
    \@hangfrom{$\ast$\@theenmark)\hskip9\p@}%
   }%
   \def\enotesize{\small\baselineskip3.75mm}%
  \else
   \def\@makeenmark{%
    \smash{\kern\z@\hbox{\@textsuperscript{\normalfont %(
     注\,\@theenmark)}}\kern\z@}}%
   \def\enoteformat{% \rightskip\z@\leftskip\z@ %(
    \@hangfrom{注\,\@theenmark)\hskip9\p@}%
   }%
   \def\enotesize{\small\baselineskip15\p@}%
  \fi
  \if@jsce@footnote@ne
   \renewcommand{\notesname}{\textbf{NOTE}}%
  \else
   \renewcommand{\notesname}{\textbf{NOTES}}%
  \fi
  \def\enoteheading{%
   \vskip1\baselineskip
   \if@english
    \noindent
    {\fontsize{10}{3.75mm}\selectfont\bfseries \notesname}\par
   \else
    \noindent
    {\normalsize \notesname}\par
   \fi
   \nopagebreak
  }%
 }{}%
 %% enumerate.sty
 \@ifpackageloaded{enumerate}{%
  \def\@@enum@[#1]{%
    \@enLab{}\let\@enThe\@enQmark
    \@enloop#1\@enum@
    \ifx\@enThe\@enQmark\@warning{The counter will not be printed.%
     ^^J\space\@spaces\@spaces\@spaces The label is: \the\@enLab}\fi
    \expandafter\edef\csname label\@enumctr\endcsname{\the\@enLab}%
    \expandafter\let\csname the\@enumctr\endcsname\@enThe
    \csname c@\@enumctr\endcsname7
    \expandafter\settowidth
              \csname leftmargin\romannumeral\@enumdepth\endcsname
              {\the\@enLab\hspace{\labelsep}}% 
    \@enum@}%
  \def\@enum@{%
   \list{\csname label\@enumctr\endcsname}%
    {\labelsep5\p@
     \expandafter\leftmargin\csname leftmargin\romannumeral\@enumdepth\endcsname
     \advance \leftmargin 10\p@
     \topsep\z@\parsep\z@\partopsep\z@\itemsep\z@
     %%
     \usecounter{\@enumctr}\def\makelabel##1{\hss\llap{##1}}}%
  }%
 }{}%
 %% jumoline
 \@ifpackageloaded{jumoline}{%
  \UnderlineDepth.75mm % .75mm
  \UMOlineThickness0.12mm
 }{}%
 %% nidanfloat
 \@ifpackageloaded{nidanfloat}{%
  \renewcommand\dblbotfraction{0.9}% 0.5
  \setcounter{dblbotnumber}{4}% 2
 }{}%
 %%%\RequirePackage[savepos]{zref}% -> Require すると正しい数値を得られない
 %% flushend
 \if@noflushend\else
  \RequirePackage{flushend}% modern [ancient]
  %\showcolsendrule %??
 \fi
}

%\newdimen\jsceenlargetextheight
\newdimen\@spaceforjsceEtitle

\newif\if@jsce@footnote@ne
\@jsce@footnote@nefalse

\AtEndDocument{%
 %% received and accepted
 \ifRAinfo@expand\else
  {\small
   \vskip\baselineskip
   \RA@info}\par
 \fi
 \@ifundefined{theendnotes}{}{%
  \ifnum\c@endnote=\@ne
   \immediate\write\@auxout{\string\global\string\@jsce@footnote@netrue}{}%
  \fi
 }%
 %% 
 \if@english\else
  \if@noflushend\else
   \zsaveposy{jsce@lastpage@posy}%
   %% this adds aux \zref@newlabel{jsce@lastpage@posy}{\posy{33744135}}
   %%  --> \Z@R@jsce@lastpage@posy
   \newbox\box@jsceEtitle
   \setbox\box@jsceEtitle\hbox{\@makeEtitle}%
   \newdimen\@dimY
   \setbox0\hbox{\expandafter\hskip\zposy{jsce@lastpage@posy}sp}%
   \@dimY=\wd0
   %\typeout{!!! jsce@lastpage@posy=\the\@dimY}%
   \@tempdima=\dimexpr \topmargin+1in\relax
   \@tempdimb=\dimexpr \paperheight-\@tempdima-\textheight\relax
   %% 右段下から頁下までの距離から\jsce@Etitle@height を引く
   \@spaceforjsceEtitle=\dimexpr \zposy{jsce@lastpage@posy}sp
    -\@tempdimb -\jsce@Etitle@height\relax
   %%\typeout{!!! @tempdimb=\the\@tempdimb}%
   %%\typeout{!!! jsce@lastpage@posy=\zposy{jsce@lastpage@posy}}%
   %%\typeout{!!! Etitleの高さ=\the\jsce@Etitle@height}%
   %\typeout{!!! @spaceforjsceEtitle=\the\@spaceforjsceEtitle}%
   \ifdim \@spaceforjsceEtitle > \z@
    \ifdim \@dimY > 770\p@
     \noindent
     \hbox to \z@{\hbox to \textwidth{\hss\box\box@jsceEtitle\hss}\hss}\par
    \else
     \atColsEnd{%
      \noindent
      \smash{\lower.5\jsce@Etitle@height\hbox to \columnwidth{\hss
       \hbox to \textwidth{\hss \box\box@jsceEtitle\hss}}}%
     }%
    \fi
   \else
    \onecolumn
    \noindent\hfil
    \box\box@jsceEtitle\par
   \fi
  \fi
 \fi
}

\pagestyle{footnombre}
\pagenumbering{arabic}
\raggedbottom
\if@twocolumn
 \twocolumn
 \flushbottom
 \sloppy
\else
  \onecolumn
\fi
\if@twoside
  \@mparswitchtrue
\else
  \@mparswitchfalse
\fi

\endinput
