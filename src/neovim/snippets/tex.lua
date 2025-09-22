--
-- LaTeX snippets - Concise, practical templates
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

return {
	-- Basic document
	s("doc", {
		t({ "\\documentclass{" }),
		c(1, { t("article"), t("report"), t("book"), t("beamer") }),
		t({ "}", "" }),
		t({ "", "\\begin{document}", "" }),
		i(2),
		t({ "", "" }),
		t({ "\\end{document}" }),
		i(0),
	}),

	-- Article template
	s("article", {
		t({ "\\documentclass[11pt]{article}", "" }),
		t({ "\\usepackage[utf8]{inputenc}", "" }),
		t({ "\\usepackage{amsmath}", "" }),
		t({ "\\usepackage{graphicx}", "" }),
		t({ "", "" }),
		t({ "\\title{" }),
		i(1, "Title"),
		t({ "}", "" }),
		t({ "\\author{" }),
		i(2, "Author"),
		t({ "}", "" }),
		t({ "\\date{\\today}", "" }),
		t({ "", "" }),
		t({ "\\begin{document}", "" }),
		t({ "\\maketitle", "", "" }),
		i(3),
		t({ "", "" }),
		t({ "\\end{document}" }),
		i(0),
	}),

	-- Beamer slide
	s("frame", {
		t({ "\\begin{frame}{" }),
		i(1, "Title"),
		t({ "}", "" }),
		i(2),
		t({ "", "" }),
		t({ "\\end{frame}" }),
		i(0),
	}),

	-- Section
	s("sec", {
		t({ "\\section{" }),
		i(1),
		t({ "}" }),
		i(0),
	}),

	s("sub", {
		t({ "\\subsection{" }),
		i(1),
		t({ "}" }),
		i(0),
	}),

	s("subsub", {
		t({ "\\subsubsection{" }),
		i(1),
		t({ "}" }),
		i(0),
	}),

	-- Environments
	s("begin", {
		t({ "\\begin{" }),
		i(1, "environment"),
		t({ "}", "" }),
		i(2),
		t({ "", "" }),
		t({ "\\end{" }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t({ "}" }),
		i(0),
	}),

	-- Figure
	s("fig", {
		t({ "\\begin{figure}[" }),
		i(1, "htbp"),
		t({ "]", "" }),
		t({ "  \\centering", "" }),
		t({ "  \\includegraphics[width=" }),
		i(2, "0.8"),
		t({ "\\textwidth]{" }),
		i(3, "image"),
		t({ "}", "" }),
		t({ "  \\caption{" }),
		i(4, "Caption"),
		t({ "}", "" }),
		t({ "  \\label{fig:" }),
		i(5, "label"),
		t({ "}", "" }),
		t({ "\\end{figure}" }),
		i(0),
	}),

	-- Table
	s("table", {
		t({ "\\begin{table}[" }),
		i(1, "htbp"),
		t({ "]", "" }),
		t({ "  \\centering", "" }),
		t({ "  \\begin{tabular}{" }),
		i(2, "c|c"),
		t({ "}", "" }),
		t({ "    " }),
		i(3, "Header1 & Header2 \\\\"),
		t({ "", "" }),
		t({ "    \\hline", "" }),
		t({ "    " }),
		i(4, "Data1 & Data2 \\\\"),
		t({ "", "" }),
		t({ "  \\end{tabular}", "" }),
		t({ "  \\caption{" }),
		i(5, "Caption"),
		t({ "}", "" }),
		t({ "  \\label{tab:" }),
		i(6, "label"),
		t({ "}", "" }),
		t({ "\\end{table}" }),
		i(0),
	}),

	-- Math environments
	s("eq", {
		t({ "\\begin{equation}", "" }),
		t({ "  " }),
		i(1),
		t({ "", "" }),
		t({ "\\end{equation}" }),
		i(0),
	}),

	s("align", {
		t({ "\\begin{align}", "" }),
		t({ "  " }),
		i(1, "a &= b \\\\"),
		t({ "", "" }),
		t({ "  " }),
		i(2, "c &= d"),
		t({ "", "" }),
		t({ "\\end{align}" }),
		i(0),
	}),

	-- Lists
	s("itemize", {
		t({ "\\begin{itemize}", "" }),
		t({ "  \\item " }),
		i(1),
		t({ "", "" }),
		t({ "  \\item " }),
		i(2),
		t({ "", "" }),
		t({ "\\end{itemize}" }),
		i(0),
	}),

	s("enumerate", {
		t({ "\\begin{enumerate}", "" }),
		t({ "  \\item " }),
		i(1),
		t({ "", "" }),
		t({ "  \\item " }),
		i(2),
		t({ "", "" }),
		t({ "\\end{enumerate}" }),
		i(0),
	}),

	-- Text formatting
	s("bf", {
		t({ "\\textbf{" }),
		i(1),
		t({ "}" }),
		i(0),
	}),

	s("it", {
		t({ "\\textit{" }),
		i(1),
		t({ "}" }),
		i(0),
	}),

	s("em", {
		t({ "\\emph{" }),
		i(1),
		t({ "}" }),
		i(0),
	}),

	s("tt", {
		t({ "\\texttt{" }),
		i(1),
		t({ "}" }),
		i(0),
	}),

	-- Math commands
	s("frac", {
		t({ "\\frac{" }),
		i(1),
		t({ "}{" }),
		i(2),
		t({ "}" }),
		i(0),
	}),

	s("sqrt", {
		t({ "\\sqrt{" }),
		i(1),
		t({ "}" }),
		i(0),
	}),

	s("sum", {
		t({ "\\sum_{" }),
		i(1, "i=1"),
		t({ "}^{" }),
		i(2, "n"),
		t({ "} " }),
		i(3),
		i(0),
	}),

	s("int", {
		t({ "\\int_{" }),
		i(1, "a"),
		t({ "}^{" }),
		i(2, "b"),
		t({ "} " }),
		i(3),
		t({ " \\, d" }),
		i(4, "x"),
		i(0),
	}),

	s("lim", {
		t({ "\\lim_{" }),
		i(1, "x \\to \\infty"),
		t({ "} " }),
		i(2),
		i(0),
	}),

	-- References
	s("ref", {
		t({ "\\ref{" }),
		i(1),
		t({ "}" }),
		i(0),
	}),

	s("cite", {
		t({ "\\cite{" }),
		i(1),
		t({ "}" }),
		i(0),
	}),

	s("label", {
		t({ "\\label{" }),
		i(1),
		t({ "}" }),
		i(0),
	}),

	-- Packages
	s("use", {
		t({ "\\usepackage" }),
		c(1, {
			{ t("["), i(1), t("]") },
			t(""),
		}),
		t("{"),
		i(2),
		t("}"),
		i(0),
	}),

	-- Greek letters
	s("alpha", { t("\\alpha") }),
	s("beta", { t("\\beta") }),
	s("gamma", { t("\\gamma") }),
	s("delta", { t("\\delta") }),
	s("epsilon", { t("\\epsilon") }),
	s("theta", { t("\\theta") }),
	s("lambda", { t("\\lambda") }),
	s("mu", { t("\\mu") }),
	s("pi", { t("\\pi") }),
	s("sigma", { t("\\sigma") }),
	s("phi", { t("\\phi") }),
	s("omega", { t("\\omega") }),

	-- Math symbols
	s("inf", { t("\\infty") }),
	s("pm", { t("\\pm") }),
	s("times", { t("\\times") }),
	s("cdot", { t("\\cdot") }),
	s("leq", { t("\\leq") }),
	s("geq", { t("\\geq") }),
	s("neq", { t("\\neq") }),
	s("approx", { t("\\approx") }),
	s("equiv", { t("\\equiv") }),
	s("implies", { t("\\implies") }),
	s("iff", { t("\\iff") }),
}
