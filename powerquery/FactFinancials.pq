// FactFinancials — annual accounts for 23 Swedish staffing companies, 2021–2025 (kSEK)
// Source: allabolag.se company pages (annual reports filed with Bolagsverket).
// In the .pbix the same 114 rows are embedded in the query; this version reads the
// cleaned CSV from this repository so the model can be rebuilt anywhere.
let
    Source   = Csv.Document(
                   Web.Contents("https://raw.githubusercontent.com/LaurasCodes/swedish-staffing-profitability/main/data/staffing_financials_2021_2025.csv"),
                   [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Headers  = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Renamed  = Table.RenameColumns(Headers, {
                   {"company", "Company"}, {"year", "Year"},
                   {"revenue_ksek", "Revenue"},
                   {"operating_result_ksek", "OperatingResult"},
                   {"result_after_financial_items_ksek", "ResultAfterFinancial"},
                   {"net_result_ksek", "NetResult"}}),
    Typed    = Table.TransformColumnTypes(Renamed, {
                   {"Company", type text}, {"Year", Int64.Type},
                   {"Revenue", type number}, {"OperatingResult", type number},
                   {"ResultAfterFinancial", type number}, {"NetResult", type number}}, "en-US")
in
    Typed
