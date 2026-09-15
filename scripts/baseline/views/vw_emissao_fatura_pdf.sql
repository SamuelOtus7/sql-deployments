-- ============================================================
-- BASELINE: dbo.vw_emissao_fatura_pdf
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_emissao_fatura_pdf]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_emissao_fatura_pdf] as 

/*
SELECT 
  emp_cd_codigo_empresa as empresaempresa
  ,faturas.fat_cd_empresa as empresafaturas
  ,emp_ds_nome as RazaoFornecedor
  ,emp_ds_cnpj as CNPJFornecedor
  ,emp_ds_end_logradouro as EnderecoFornecedor
  ,emp_ds_ie as InscricaoEstadualFornecedor
  ,emp_ds_end_cidade as MunicipioFornecedor
  ,fcl_nome_cliente as NomeCliente
  ,fcl_ds_endereco as EnderecoCliente
  ,fcl_ds_municipio as MunicipioCliente
  ,fcl_nr_cnpj as CNPJCliente
  ,fcl_ds_inscricao_est as InscricaoEstadualCliente
  ,fcl_ds_praca_pagamento as PracaPagamento
  ,CAST(fat_dt_vencimento as date) as DataVencimento
  ,CAST(fat_dt_emissao as date) as DataEmissao
  ,fat_nr_Fatura as Fatura
  ,fat_vl_fatura as ValorFatura
  ,fat_ds_observacao as Observacao
  ,fat_ds_valor_extenso as ValorExtenso
  ,Descontos
  ,Correcao
  ,fat_cd_fatura as IDFATURA
  ,cli.cli_ds_logo_header_path LogoCliente
  ,'Q2_01_2025' PeriodoApurado 
  ,'DESP00008' CodigoServico
  ,'16/01/2025 ao 31/01/2025' DataApurada 
  ,'Last Mile HUB SHPX' ProdutoServico
  ,replace(replace(fcl_nr_cnpj, '/',''),'-','') IdTomador
  ,'Last Mile HUB SHPX' TipoServico
  ,'SPXBR-PR-72535' IdPO
  ,fat_vl_fatura ValorBruto
  ,0 ValorDesconto
from 
  tb_fin_faturas faturas
  left join tb_empresas empresas ON empresas.emp_cd_codigo_empresa = faturas.fat_cd_empresa
  left join tb_fin_fat_cliente cliente on cliente.fcl_cd_fat_cliente = faturas.fat_cd_fat_cliente
  left join tb_clientes cli on cliente.fcl_cd_cliente = cli.cli_cd_codigo_cliente

GO
*/


SELECT 
  emp_cd_codigo_empresa as empresaempresa
  ,faturas.fat_cd_empresa as empresafaturas
  ,emp_ds_nome as RazaoFornecedor
  ,emp_ds_cnpj as CNPJFornecedor
  ,emp_ds_end_logradouro as EnderecoFornecedor
  ,emp_ds_ie as InscricaoEstadualFornecedor
  ,emp_ds_end_cidade as MunicipioFornecedor
  ,fcl_nome_cliente as NomeCliente
  ,fcl_ds_endereco as EnderecoCliente              
  ,fcl_ds_municipio as MunicipioCliente
  ,fcl_nr_cnpj as CNPJCliente
  ,fcl_ds_inscricao_est as InscricaoEstadualCliente
  ,fcl_ds_praca_pagamento as PracaPagamento
  ,CAST(fat_dt_vencimento as date) as DataVencimento
  ,CAST(fat_dt_emissao as date) as DataEmissao
  ,fat_nr_Fatura as Fatura
  ,fat_vl_fatura as ValorFatura
  ,fat_ds_observacao as Observacao
  ,fat_ds_valor_extenso as ValorExtenso
  ,Descontos
  ,Correcao                    
  ,fat_cd_fatura as IDFATURA
  ,cli.cli_ds_logo_header_path LogoCliente
  ,fcl_ds_lote as  PeriodoApurado 
  ,'DESP00008' CodigoServico
  ,CONVERT(varchar(10),
    CASE 
        WHEN DAY(CAST(fat_dt_emissao AS date)) <= 15
            THEN DATEFROMPARTS(
                    YEAR(DATEADD(month,-1,CAST(fat_dt_emissao AS date))),
                    MONTH(DATEADD(month,-1,CAST(fat_dt_emissao AS date))),
                    15
                 )
        ELSE DATEFROMPARTS(
                YEAR(CAST(fat_dt_emissao AS date)),
                MONTH(CAST(fat_dt_emissao AS date)),
                1
             )
    END
,103)
+ ' ao ' +
CONVERT(varchar(10),
    CASE 
        WHEN DAY(CAST(fat_dt_emissao AS date)) <= 15
            THEN EOMONTH(DATEADD(month,-1,CAST(fat_dt_emissao AS date)))
        ELSE DATEFROMPARTS(
                YEAR(CAST(fat_dt_emissao AS date)),
                MONTH(CAST(fat_dt_emissao AS date)),
                15
             )
    END
,103) AS DataApurada
  ,'Last Mile HUB SHPX' ProdutoServico
  ,replace(replace(fcl_nr_cnpj, '/',''),'-','') IdTomador
  ,fcl_ds_praca_pagamento TipoServico
  ,fat_ds_observacao IdPO
  ,fat_vl_fatura ValorBruto
  ,Descontos as   ValorDesconto
,fat_cd_Fatura
from 
  tb_fin_faturas faturas
  left join tb_empresas empresas ON empresas.emp_cd_codigo_empresa = faturas.fat_cd_empresa
  left join tb_fin_fat_cliente cliente on cliente.fcl_cd_fat_cliente = faturas.fat_cd_fat_cliente
  left join tb_clientes cli on cliente.fcl_cd_cliente = cli.cli_cd_codigo_cliente






GO
