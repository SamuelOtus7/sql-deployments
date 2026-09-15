-- ============================================================
-- BASELINE: dbo.vw_lista_produtividade
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_lista_produtividade]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_lista_produtividade] as 

select
idtransportadora
,DataReferencia
,Idrota as Rota
,NomeMotorista
,'' as Numero
,Placa
,ServiceCenter as Base
,case when bss_in_xpt = 1 then 'XPT' else '' end as HRS
,bss_ds_regiao as Regiao
,TipoVeiculo Operacao
,'' as UTI
,'' as PAS
,'' as VUC
,'' as Vl_PAC
,'' as ValorFinal
,TotalPacotes as Pac
,PacotesNaoEntregue as Insucessos
,QuantidadeParadas as PAR
,'' as AjuMeli
,'' as Apoio
,CASE
    WHEN CONCAT(OrigemSaida, ServiceCenter) = 'XPTSSP7' THEN 'XPT BRL'
    WHEN CONCAT(OrigemSaida, ServiceCenter) = 'XPTSSP17' THEN 'XPT AME'
    ELSE 'MELI'
END CentroCusto
,'' Observacao
,CASE 
    WHEN PacotesNaoEntregue = 0 THEN ''
    WHEN (PacotesNaoEntregue / cast(TotalPacotes as decimal(9,2))) > 0.1 THEN 'Nao'
    ELSE ''
END AS Atingimento
,CASE 
        WHEN 
			bss_in_xpt = 1 
		THEN FORMAT(DataReferencia, 'ddd')
        
		ELSE 'NaoXPT'
    END AS Carregamento
,0 Pagos
,'' Valor
,ServiceCenter as SVC2
,   CASE 
        WHEN servicecenter = 'SC_VG' THEN 1
        WHEN servicecenter = 'SC_ZS' THEN 2
        WHEN servicecenter = 'SSP15' THEN 3
        WHEN servicecenter = 'SSP17' THEN 4
        WHEN servicecenter = 'SSP19' THEN 5
        WHEN servicecenter = 'SSP6' THEN 6
        WHEN servicecenter = 'SSP21' THEN 7
        WHEN servicecenter = 'SSP7' THEN 8
        WHEN servicecenter = 'SSP16' THEN 9
        WHEN servicecenter = 'SSP18' THEN 10
        WHEN servicecenter = 'SSP3' THEN 11
        WHEN servicecenter = 'SSP5' THEN 12
        WHEN servicecenter = 'SSP8' THEN 13
        WHEN servicecenter = 'SSP9' THEN 13
        WHEN servicecenter = 'SSP20' THEN 14
        WHEN servicecenter = 'SSP13' THEN 15
        WHEN servicecenter = 'SSP4' THEN 16
        ELSE 9999
    END AS Seq
,'' as KM
,'' as PDG
,'' as MAIRIP
,'' as [+78]
,'' as AJU
,'' as ValorFinal2
,'' as [xxx]
,'' as BONUS
,'' as INICIAL
,'' as FINAL
,'' as DIF
,'' as RODADO



from vw_rotas as a
inner join tb_bases as b
on a.IdTransportadora = b.bss_cd_idtransportadora
and a.ServiceCenter = b.bss_ds_sigla

where datareferencia >=  DATEADD(DAY, -30, GETDATE())-- Alterado por conta da lentidão na base, decidido em Call com Samuel 17/10/2025
GO
