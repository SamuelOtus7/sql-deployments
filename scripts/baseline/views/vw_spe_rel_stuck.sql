-- ============================================================
-- BASELINE: dbo.vw_spe_rel_stuck
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_spe_rel_stuck]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[vw_spe_rel_stuck] as

select 
	 a.DataReferencia
    ,a.IdInterno
	,a.IdStation
	,a.IdTransportadora	
	,a.IdMotorista
	,t1.tds_ds_traducao StatusEntrega
	,b.StatusEntrega StatusEntregaShopee	
	,b.SubStatus SubStatusShopee	
	,b.StatusPacote
    ,a.NomeHub
	--,c.FaixaFaltaStuck
	--,c.IdFaixaFaltaStuck
	--,datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia)) as DiasVencimento
	,CASE 
    WHEN DATEDIFF(d, CAST(GETDATE() AS date), DATEADD(d, 20, a.DataReferencia)) < 0 
        THEN 0
    ELSE DATEDIFF(d, CAST(GETDATE() AS date), DATEADD(d, 20, a.DataReferencia))
END AS DiasVencimento

	,a.CodigoRota
	,b.CodigoPacote

	,case 
		when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))  <= -1 then 'Vencido'
		when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))  between  0 and  5 then 'Hoje a 5 dias'
		when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))  between  6 and 9 then '6 a 9 dias'
		when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))  between 10 and 14 then '10 a 14 dias'
		--when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))  between 16 and 20 then '16 a 20 dias'
		when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))  >= 15  then 'Mais de 15 dias'
	else null end FaixaFaltaStuck

	,case 
		when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))  <= -1 then 0
		when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))  between  0 and  5 then 1
		when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))  between  6 and 10 then 2
		when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))  between 11 and 15 then 3
		when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))  between 16 and 20 then 4
		when datediff(d, cast(getdate() as date), dateadd(d,20,a.DataReferencia))   >= 21 then 5
	else null end IdFaixaFaltaStuck

    

	,case when t1.tds_ds_traducao = 'Pendente'		then 1 else 0 end as Pendente 
	,case when t1.tds_ds_traducao = 'Entregue'		then 1 else 0 end as Entregue
	,case when t1.tds_ds_traducao = 'Não Entregue' then 1 else 0 end as NaoEntregue
	,1 as Stuck
	-- ,case when c.StatusPacote is not null       then 1 else 0 end as Stuck



from [dbo].[vw_rotas_spe_v4] as a
left join tb_spe_pacotes_v5 as b
on 
a.IdTransportadora	 = b.IdTransportadora	
and a.DataReferencia	 = b.DataReferencia	
and a.CodigoRota	= b.CodigoRota	 
left join tb_ml_traducoes t1 with(nolock) on b.StatusEntrega = t1.tds_vl_json and t1.tds_nm_tabela = 'tb_spe_pacotes' and t1.tds_nm_campo = 'StatusEntrega'
				   
-- left join  [dbo].[vw_pacotes_spe_v4_pendentes] as c
-- on 
--     b.IdTransportadora   = c.IdTransportadora   
-- and b.DataReferencia	 = c.DataReferencia	 
-- and b.CodigoRota		 = c.CodigoRota		 
-- and b.CodigoPacote		 = c.CodigoPacote		 

where 1=1 
and a.DataReferencia between GETDATE()-90 and GETDATE()-1
and b.StatusEntrega in ('Return_Hub_Onhold','Return_Hub_Returning','Return_LMHub_Returning', 'OnHold','Return_LMHub_Onhold')
and b.Excluido = 0 
-- and b.StatusPacote <> 'Delivered'
--and b.StatusPacote is not null
--and a.CodigoRota = 'AT202312291F8O2'
-- and b.codigopacote = 'BR240121454596Z'



GO
