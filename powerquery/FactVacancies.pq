// FactVacancies — job vacancies in Sweden, seasonally adjusted, quarterly 2009Q1 onward
// Source: Statistics Sweden (SCB), table TAB6406 "Lediga jobb, hela ekonomin, säsongrensad
// efter näringsgren SNI 2007", read live from the PxWebApi v2 (anonymous access).
let
    Src = Csv.Document(
              Web.Contents("https://statistikdatabasen.scb.se/api/v2/tables/TAB6406/data",
                  [Query = [
                      lang = "sv",
                      outputFormat = "csv",
                      outputFormatParams = "SeparatorSemicolon",
                      #"valueCodes[LedJobbTyp]"    = "LJtot",
                      #"valueCodes[SNI2007Naring]" = "A-S,M-N",
                      #"valueCodes[ContentsCode]"  = "000007J4",   // antal, säsongrensad
                      #"valueCodes[Tid]"           = "*"]]),
              [Delimiter = ";", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    H     = Table.PromoteHeaders(Src, [PromoteAllScalars = true]),
    // first two columns are the dimension codes (type of vacancy, industry)
    Named = Table.RenameColumns(H, {{Table.ColumnNames(H){0}, "Type"}, {Table.ColumnNames(H){1}, "SNI"}}),
    // wide -> long: one row per industry and quarter
    U     = Table.UnpivotOtherColumns(Named, {"Type", "SNI"}, "Attr", "Value"),
    Q     = Table.AddColumn(U, "Quarter", each Text.AfterDelimiter([Attr], " "), type text),
    // SCB marks unpublished cells with ".." — M-N is not published in this series
    F     = Table.SelectRows(Q, each [Value] <> ".." and [Value] <> ""),
    V     = Table.TransformColumns(F, {{"Value", each Number.From(_, "en-US"), type number}}),
    // "2026K2" -> first day of the quarter, for a continuous date axis
    D     = Table.AddColumn(V, "QuarterStart",
                each #date(Number.From(Text.Start([Quarter], 4)), (Number.From(Text.End([Quarter], 1)) - 1) * 3 + 1, 1), type date),
    I     = Table.AddColumn(D, "Industry",
                each if [SNI] = "A-S" then "All industries" else "Business support & staffing (M-N)", type text),
    R     = Table.RenameColumns(Table.SelectColumns(I, {"Industry", "Quarter", "QuarterStart", "Value"}), {{"Value", "Vacancies"}})
in
    R
