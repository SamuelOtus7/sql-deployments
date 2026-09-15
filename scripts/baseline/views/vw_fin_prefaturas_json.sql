-- ============================================================
-- BASELINE: dbo.vw_fin_prefaturas_json
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_prefaturas_json]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT count(distinct json_data) as qtde from tb_fin_prefatura_json
--SELECT * from tb_fin_prefatura_json where id > 47 order by 2 desc
create view [dbo].[vw_fin_prefaturas_json]
as
select pre_invoices.* 
from (SELECT preinvoices.* from (select * from tb_fin_prefatura_json where id >= 48) as base
        cross apply openjson(json_data)
        with (preinvoices nvarchar(max) '$.pre_invoices' as json) as preinvoices
    ) as base
    cross apply openjson(preinvoices)
    with (
        id nvarchar(max)  '$.id',
        carrier_id nvarchar(max)  '$.carrier_id',
        cost nvarchar(max)  '$.cost',
        carrier_name nvarchar(max)  '$.carrier_name',
        period_name nvarchar(max)  '$.period.name',
        type nvarchar(max)  '$.type',
        driver_id nvarchar(max)  '$.driver_id',
        site_id nvarchar(max)  '$.site_id',
        step_type nvarchar(max)  '$.step_type',
        product nvarchar(max)  '$.product',
        invoice_id nvarchar(max)  '$.invoice_id',
        ticket_id nvarchar(max)  '$.ticket_id',
        sap_id nvarchar(max)  '$.sap_id',
        provision_number nvarchar(max)  '$.provision_number',
        accounting_period nvarchar(max)  '$.accounting_period',
        invalid nvarchar(max)  '$.invalid',
        error nvarchar(max)  '$.error',
        additional_cost nvarchar(max)  '$.additional_cost',
        penalties_cost nvarchar(max)  '$.penalties_cost',
        penalties_cap_cost nvarchar(max)  '$.penalties_cap_cost',
        cap_cost nvarchar(max)  '$.cap_cost',
        tax_icms_cost nvarchar(max)  '$.tax_icms_cost',
        tax_iss_cost nvarchar(max)  '$.tax_iss_cost',
        tax_total_cost nvarchar(max)  '$.tax_total_cost',
        tax_icms_detail_cost nvarchar(max)  '$.tax_icms_detail_cost',
        total_cost nvarchar(max)  '$.total_cost',
        status nvarchar(max)  '$.status',
        status_reason nvarchar(max)  '$.status_reason',
        period_id nvarchar(max)  '$.period.id',
        period_type nvarchar(max)  '$.period.period_type',
        period_date_from nvarchar(max)  '$.period.date_from',
        period_date_to nvarchar(max)  '$.period.date_to',
        period_order nvarchar(max)  '$.period.order',
        date_created nvarchar(max)  '$.date_created',
        last_updated nvarchar(max)  '$.last_updated',
        driver_name nvarchar(max)  '$.driver_name',
        enable_invoice_account nvarchar(max)  '$.enable_invoice_account',
        isCTE nvarchar(max)  '$.isCTE',
        isAccountingAutomatic nvarchar(max)  '$.isAccountingAutomatic',
        pre_invoice_data_id nvarchar(max)  '$.pre_invoice_requirements[0].id',
        pre_invoice_id nvarchar(max)  '$.pre_invoice_requirements[0].pre_invoice_id',
        pre_invoice_type nvarchar(max)  '$.pre_invoice_requirements[0].type',
        pre_invoice_city_id nvarchar(max)  '$.pre_invoice_requirements[0].city_id',
        pre_invoice_city_code nvarchar(max)  '$.pre_invoice_requirements[0].city_code',
        pre_invoice_total_cost nvarchar(max)  '$.pre_invoice_requirements[0].total_cost',
        pre_invoice_document_id nvarchar(max)  '$.pre_invoice_requirements[0].fiscal_document.id',
        pre_invoice_document_type nvarchar(max)  '$.pre_invoice_requirements[0].fiscal_document.type',
        pre_invoice_document_date nvarchar(max)  '$.pre_invoice_requirements[0].fiscal_document.date',
        pre_invoice_document_number nvarchar(max)  '$.pre_invoice_requirements[0].fiscal_document.number',
        pre_invoice_document_number_sap nvarchar(max)  '$.pre_invoice_requirements[0].fiscal_document.number_sap',
        pre_invoice_document_total_cost nvarchar(max)  '$.pre_invoice_requirements[0].fiscal_document.total_cost',
        pre_invoice_document_subtotal_cost nvarchar(max)  '$.pre_invoice_requirements[0].fiscal_document.subtotal_cost',
        pre_invoice_document_status nvarchar(max)  '$.pre_invoice_requirements[0].fiscal_document.status',
        pre_invoice_document_datecreated nvarchar(max)  '$.pre_invoice_requirements[0].fiscal_document.date_created'
    ) as pre_invoices



GO
