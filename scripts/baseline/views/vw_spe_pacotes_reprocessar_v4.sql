-- ============================================================
-- BASELINE: dbo.vw_spe_pacotes_reprocessar_v4
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_spe_pacotes_reprocessar_v4]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select count(*) from vw_spe_pacotes_reprocessar_v4
--select count(*) from [vw_coletar_km_rotas]


--SELECT * FROM tb_dra_coleta
--WHERE dac_ds_tipo_coleta = 'SPE4_DETAILS'
--and cast(dac_dh_referencia as date) between '2024-07-16' and '2024-07-17'



--select *  from tb_clientes

---- select count(*) from vw_spe_pacotes_reprocessar_v4
--3149

CREATE view  [dbo].[vw_spe_pacotes_reprocessar_v4] as



--select 
--	CodigoPacote,
--	IdTransportadora,
--	6036 as IdStation

--from tb_spe_pacotes_v4
--where idtransportadora = 20230009
--and datareferencia between '2024-04-16' and '2024-04-30'
--and latitude is null
--and longitude is null
--and excluido = 0
--and codigorota in (
--select codigorota 
--from tb_spe_rotas_v4
--where idtransportadora = 20230009
--and datareferencia between '2024-04-16' and '2024-04-30'
--and excluido = 0
--and idstation = 6036
--)

select top 50000 *

from (
	
--	select 
--'BR245095586248E'  CodigoPacote
--, 	20230008 as IdTransportadora
--, 5025 as IdStation

--union all

	select DISTINCT 
		p.CodigoPacote,
		p.IdTransportadora,
		p.IdStation
		--Idtransportadora
	from
		tb_spe_pacotes_para_reprocessar_v4 p with(nolock)
		inner join tb_clientes cliente on p.IdTransportadora = cliente.cli_id_shopee
		left join tb_dra_coleta c with(nolock) on p.CodigoPacote = c.dac_ds_contexto 
								and p.IdTransportadora = c.dac_cd_transportadora
								and c.dac_ds_tipo_coleta = 'SPE4_DETAILS'
								and c.dac_dh_escrita >= cast(getdate() as date)
		left join (
			select distinct right(dec_ds_erro,15) as BR
			from tb_dra_erros_coleta
			where dec_ds_tipo_coleta = 'SPE4_DETAILS'
				and (
						dec_ds_erro like 'Error: Invalid request: Falha ao verificar a permissão do usuário%' or
						dec_ds_erro like 'Error: Invalid request: unauthorized codigoPacote:%' or
						dec_ds_erro like 'Error: Invalid request: SPX-BasicServiceApi-live-b%' or
						dec_ds_erro like 'Error: Invalid request: fail to verify user permis%'
					)
		) erros on p.CodigoPacote = erros.BR

		left join tb_spe_pacotes_v4 as pacotes
		on p.codigopacote = pacotes.codigopacote
		and p.IdTransportadora = pacotes.IdTransportadora

	where 1=1
	and	c.dac_cd_coleta is null
	and cliente.cli_in_ativo = 1
	and erros.BR is null
    -- and p.IdTransportadora = 20230008
    and pacotes.StatusEntrega in ('Pending','Assigned')
    -- and pacotes.CodigoPacote IN ('BR246527693014Q','BR247110668058V','BR247376187318F','BR248859445806B','BR249079936435B')
    -- and pacotes.datareferencia >= cast(getdate() as date)
    	

	union all

	select 
		 a.CodigoPacote
		,a.IdTransportadora
		,a.IdStation

	from tb_spe_pacotes_para_reprocessar_v4_TO as a
	left join [tb_spe_rotas_v4] as b
	on a.Codigorota = b.Codigorota
	--and 0 = b.excluido

	left join [vw_pacotes_spe_v4] as c
	on a.CodigoPacote = c.CodigoPacote

	where 1=1
	and (StatusEntrega = 'Pendente' or StatusEntrega is null )
	--and b.datareferencia is null
	and b.datareferencia between cast(getdate()-2 as date) and cast(getdate() as date)
	-- and a.codigorota = 'TO20240713BF1CL'

	--union all



	--select 
	-- a.CodigoPacote
	--,a.IdTransportadora
	--,b.IdStation

	--from [vw_pacotes_spe_v4] as a

	--inner join vw_rotas_spe_v4 as b
	--on a.codigorota = b.codigorota

	--where 1=1
	--and a.DataReferencia = cast(getdate() as date)
	--and datediff(hour,a.DataAtualizacao,getdate()) >= 5
	--and a.IdTransportadora = 20230008
	--and IdStation = 5055
	--and StatusEntrega = 'Pendente'

) as a

-- select distinct *  from tb_spe_pacotes_para_reprocessar_v4 
GO
