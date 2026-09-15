-- ============================================================
-- BASELINE: dbo.vw_pacotes_spe_v4_pendentes
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_spe_v4_pendentes]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO


CREATE view [dbo].[vw_pacotes_spe_v4_pendentes]
as

select 
	a.DataReferencia
	,dateadd(d,10,a.DataReferencia) DatStuck
	,case 
		when FaltaParaStuck <= -1 then 'Vencido'
		when FaltaParaStuck between  0 and  5 then 'Hoje a 5 dias'
		when FaltaParaStuck between  6 and 10 then '6 a 10 dias'
		when FaltaParaStuck between 11 and 15 then '11 a 15 dias'
		when FaltaParaStuck between 16 and 20 then '16 a 20 dias'
		when FaltaParaStuck >= 21  then 'Mais de 20 dias'
	else null end FaixaFaltaStuck
	,case 
		when FaltaParaStuck <= -1 then 0
		when FaltaParaStuck between  0 and  5 then 1
		when FaltaParaStuck between  6 and 10 then 2
		when FaltaParaStuck between 11 and 15 then 3
		when FaltaParaStuck between 16 and 20 then 4
		when FaltaParaStuck  >= 21 then 5
	else null end IdFaixaFaltaStuck

	,FaltaParaStuck as DiasVencimento
	,a.IdTransportadora
	,a.IdRotaInterno
	,a.CodigoRota
	,a.CodigoPacote
	,rota.Motorista
	,a.StatusEntrega
	,a.StatusPacote
	,rota.IdStation
    ,a.SituacaoPacote

FROM
	(
		select 
				IdRotaInterno
			,CodigoRota
			,CodigoPacote
			,IdTransportadora
			,DataReferencia
			,StatusEntrega
            -- ,SubStatus
			,row_number() over(partition by CodigoPacote order by DataReferencia desc) rank
			,SubStatus as StatusPacote
			,datediff(d, cast(getdate() as date), dateadd(d,20,DataReferencia)) as FaltaParaStuck
            ,StatusPacote as SituacaoPacote

		from [vw_pacotes_spe_v4] 
		where 1=1
		and DataReferencia < cast(getdate() as date)
        
		--and CodigoRota is not null
    --    and CodigoPacote = 'BR240121454596Z'

	) as A

left join  [dbo].[vw_rotas_spe_v4] as rota
on rota.CodigoRota = a.CodigoRota

WHERE 1=1
	AND a.rank = 1
	AND StatusPacote IS NOT NULL
	AND StatusPacote <> 'LMHub_Received'
	And StatusEntrega <> 'Entregue'
	And StatusEntrega <> 'Delivered'
	And StatusPacote <> 'Delivered'
	And SituacaoPacote <> 'Delivered'
    and StatusEntrega <> 'Cancelled'
	--and StatusPacote = 'Lost'
    -- and CodigoPacote = 'BR240121454596Z'

--order by 1 desc 

	--TO202312144JJRR	BR231659693884Q

GO
