--
-- LaTeX snippets - Modern templates for LaTeX document creation
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Helper functions
local function get_filename()
  return vim.fn.expand('%:t') or 'untitled.tex'
end

local function get_project_name()
  return vim.fn.expand('%:p:h:t') or 'project'
end

local function get_date()
  return os.date('%m/%d/%y')
end

local function get_year()
  return os.date('%Y')
end

return {
  -- Document header
  s("header", {
    t({"%"}),
    t({"%  "}), f(get_filename, {}),
    t({"%  "}), f(get_project_name, {}),
    t({"%"}),
    t({"%  Created by Illya Starikov on "}), f(get_date, {}), t({"."}),
    t({"%  Copyright "}), f(get_year, {}), t({". Illya Starikov. All rights reserved."}),
    t({"%"}),
    t({""}),
    i(0)
  }),

  -- Article document template
  s("article", {
    t({"\\RequirePackage[l2tabu, orthodox]{nag}"}),
    t({"\\documentclass["}), i(1, "12pt"), t({"]{article}"}),
    t({""}),
    t({"% Essential packages"}),
    t({"\\usepackage[utf8]{inputenc}"}),
    t({"\\usepackage[T1]{fontenc}"}),
    t({"\\usepackage{lmodern}"}),
    t({"\\usepackage{microtype}"}),
    t({"\\usepackage{geometry}"}),
    t({""}),
    t({"% Math packages"}),
    t({"\\usepackage{amsmath,amssymb,amsthm}"}),
    t({"\\usepackage{mathtools}"}),
    t({""}),
    t({"% Graphics and tables"}),
    t({"\\usepackage{graphicx}"}),
    t({"\\usepackage{booktabs}"}),
    t({"\\usepackage{array}"}),
    t({""}),
    t({"% References and citations"}),
    t({"\\usepackage[hidelinks]{hyperref}"}),
    t({"\\usepackage{cleveref}"}),
    t({""}),
    t({"% Document information"}),
    t({"\\title{"}), i(2, "Document Title"), t({"}"}),
    t({"\\author{Illya Starikov}"}),
    t({"\\date{\\today}"}),
    t({""}),
    t({"\\begin{document}"}),
    t({"\\maketitle"}),
    t({""}),
    i(3, "% Document content"),
    t({""}),
    t({"\\end{document}"}),
    i(0)
  }),

  -- Beamer presentation template
  s("beamer", {
    t({"\\documentclass[aspectratio=169]{beamer}"}),
    t({""}),
    t({"% Theme and appearance"}),
    t({"\\usetheme{"}), i(1, "Madrid"), t({"}"}),
    t({"\\usecolortheme{"}), i(2, "default"), t({"}"}),
    t({""}),
    t({"% Essential packages"}),
    t({"\\usepackage[utf8]{inputenc}"}),
    t({"\\usepackage[T1]{fontenc}"}),
    t({"\\usepackage{lmodern}"}),
    t({""}),
    t({"% Math packages"}),
    t({"\\usepackage{amsmath,amssymb}"}),
    t({""}),
    t({"% Graphics"}),
    t({"\\usepackage{graphicx}"}),
    t({""}),
    t({"% Presentation information"}),
    t({"\\title{"}), i(3, "Presentation Title"), t({"}"}),
    t({"\\subtitle{"}), i(4, "Subtitle"), t({"}"}),
    t({"\\author{Illya Starikov}"}),
    t({"\\institute{"}), i(5, "Institution"), t({"}"}),
    t({"\\date{\\today}"}),
    t({""}),
    t({"\\begin{document}"}),
    t({""}),
    t({"\\frame{\\titlepage}"}),
    t({""}),
    i(6, "% Slides content"),
    t({""}),
    t({"\\end{document}"}),
    i(0)
  }),

  -- Figure environment
  s("figure", {
    t({"\\begin{figure}["}), i(1, "htbp"), t({"]"}),
    t({"    \\centering"}),
    t({"    \\includegraphics[width="}), i(2, "0.8"), t({"\\textwidth]{"}), i(3, "filename"), t({"}"}),
    t({"    \\caption{"}), i(4, "Caption text"), t({"}"}),
    t({"    \\label{fig:"}), i(5, "label"), t({"}"}),
    t({"\\end{figure}"}),
    i(0)
  }),

  -- Table environment
  s("table", {
    t({"\\begin{table}["}), i(1, "htbp"), t({"]"}),
    t({"    \\centering"}),
    t({"    \\caption{"}), i(2, "Table caption"), t({"}"}),
    t({"    \\label{tab:"}), i(3, "label"), t({"}"}),
    t({"    \\begin{tabular}{"}), i(4, "lcc"), t({"}"}),
    t({"        \\toprule"}),
    t({"        "}), i(5, "Header 1 & Header 2 & Header 3 \\\\"),
    t({"        \\midrule"}),
    t({"        "}), i(6, "Data 1 & Data 2 & Data 3 \\\\"),
    t({"        \\bottomrule"}),
    t({"    \\end{tabular}"}),
    t({"\\end{table}"}),
    i(0)
  }),

  -- Equation environments
  s("equation", {
    t({"\\begin{equation}"}),
    t({"    "}), i(1, "E = mc^2"),
    t({"    \\label{eq:"}), i(2, "label"), t({"}"}),
    t({"\\end{equation}"}),
    i(0)
  }),

  s("align", {
    t({"\\begin{align}"}),
    t({"    "}), i(1, "f(x) &= ax^2 + bx + c \\\\"),
    t({"    "}), i(2, "f'(x) &= 2ax + b"),
    t({"    \\label{eq:"}), i(3, "label"), t({"}"}),
    t({"\\end{align}"}),
    i(0)
  }),

  -- List environments
  s("itemize", {
    t({"\\begin{itemize}"}),
    t({"    \\item "}), i(1, "First item"),
    t({"    \\item "}), i(2, "Second item"),
    t({"    \\item "}), i(3, "Third item"),
    t({"\\end{itemize}"}),
    i(0)
  }),

  s("enumerate", {
    t({"\\begin{enumerate}"}),
    t({"    \\item "}), i(1, "First item"),
    t({"    \\item "}), i(2, "Second item"),
    t({"    \\item "}), i(3, "Third item"),
    t({"\\end{enumerate}"}),
    i(0)
  }),

  -- Theorem environments
  s("theorem", {
    t({"\\begin{theorem}"}), i(1, "[Optional name]"),
    t({"    "}), i(2, "Theorem statement"),
    t({"\\end{theorem}"}),
    i(0)
  }),

  s("proof", {
    t({"\\begin{proof}"}),
    t({"    "}), i(1, "Proof content"),
    t({"\\end{proof}"}),
    i(0)
  }),

  s("definition", {
    t({"\\begin{definition}"}), i(1, "[Optional name]"),
    t({"    "}), i(2, "Definition content"),
    t({"\\end{definition}"}),
    i(0)
  }),

  -- TikZ figure
  s("tikz", {
    t({"\\begin{figure}[htbp]"}),
    t({"    \\centering"}),
    t({"    \\begin{tikzpicture}"}),
    t({"        "}), i(1, "\\draw (0,0) -- (1,1);"),
    t({"    \\end{tikzpicture}"}),
    t({"    \\caption{"}), i(2, "TikZ figure caption"), t({"}"}),
    t({"    \\label{fig:"}), i(3, "tikz-label"), t({"}"}),
    t({"\\end{figure}"}),
    i(0)
  }),

  -- Bibliography
  s("bibliography", {
    t({"\\bibliographystyle{"}), i(1, "plain"), t({"}"}),
    t({"\\bibliography{"}), i(2, "references"), t({"}"}),
    i(0)
  }),

  -- Citations
  s("cite", {
    t({"\\cite{"}), i(1, "reference-key"), t({"}"}),
    i(0)
  }),

  s("citep", {
    t({"\\citep{"}), i(1, "reference-key"), t({"}"}),
    i(0)
  }),

  s("citet", {
    t({"\\citet{"}), i(1, "reference-key"), t({"}"}),
    i(0)
  }),

  -- Cross-references
  s("ref", {
    t({"\\ref{"}), i(1, "label"), t({"}"}),
    i(0)
  }),

  s("cref", {
    t({"\\cref{"}), i(1, "label"), t({"}"}),
    i(0)
  }),

  -- Text formatting
  s("textbf", {
    t({"\\textbf{"}), i(1, "bold text"), t({"}"}),
    i(0)
  }),

  s("textit", {
    t({"\\textit{"}), i(1, "italic text"), t({"}"}),
    i(0)
  }),

  s("emph", {
    t({"\\emph{"}), i(1, "emphasized text"), t({"}"}),
    i(0)
  }),

  -- Sectioning
  s("section", {
    t({"\\section{"}), i(1, "Section Title"), t({"}"}),
    t({"\\label{sec:"}), i(2, "label"), t({"}"}),
    t({""}),
    i(3),
    i(0)
  }),

  s("subsection", {
    t({"\\subsection{"}), i(1, "Subsection Title"), t({"}"}),
    t({"\\label{subsec:"}), i(2, "label"), t({"}"}),
    t({""}),
    i(3),
    i(0)
  }),

  -- Math symbols and operators
  s("frac", {
    t({"\\frac{"}), i(1, "numerator"), t({"}{"}), i(2, "denominator"), t({"}"}),
    i(0)
  }),

  s("sqrt", {
    t({"\\sqrt{"}), i(1, "expression"), t({"}"}),
    i(0)
  }),

  s("sum", {
    t({"\\sum_{"}), i(1, "i=1"), t({"}^{"}), i(2, "n"), t({"} "}), i(3, "a_i"),
    i(0)
  }),

  s("int", {
    t({"\\int_{"}), i(1, "a"), t({"}^{"}), i(2, "b"), t({"} "}), i(3, "f(x)"), t({" dx"}),
    i(0)
  }),

  -- Beamer frame
  s("frame", {
    t({"\\begin{frame}{"}), i(1, "Frame Title"), t({"}"}),
    t({"    "}), i(2, "Frame content"),
    t({"\\end{frame}"}),
    i(0)
  }),

  -- Algorithm environment
  s("algorithm", {
    t({"\\begin{algorithm}"}),
    t({"    \\caption{"}), i(1, "Algorithm caption"), t({"}"}),
    t({"    \\label{alg:"}), i(2, "label"), t({"}"}),
    t({"    \\begin{algorithmic}"}),
    t({"        \\State "}), i(3, "Algorithm step"),
    t({"    \\end{algorithmic}"}),
    t({"\\end{algorithm}"}),
    i(0)
  }),
}