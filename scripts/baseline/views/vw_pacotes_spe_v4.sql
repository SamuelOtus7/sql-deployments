-- ============================================================
-- BASELINE: dbo.vw_pacotes_spe_v4
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_spe_v4]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[vw_pacotes_spe_v4]
as

select distinct 
	rotas.Id IdRotaInterno,
	rotas.CodigoRota,
	pacotes.IdTransportadora,
	pacotes.CodigoPacote,
	pacotes.DataReferencia,
	t1.tds_ds_traducao StatusEntrega,
	isnull(t2.tds_ds_traducao, pacotes.SubStatus) SubStatus,
	pacotes.DataHoraEntrega,
	pacotes.DataHoraEntrega as  DataAtualizacao,
	case when pacotes.URLImagem is not null then 'https://spx.shopee.com.br' + pacotes.URLImagem end URLImagem,
	pacotes.StatusEntrega StatusEntregaShopee,
	pacotes.SubStatus SubStatusShopee,
	pacotes.CEP,
	pacotes.StatusPacote,
    case when DATEPART(hh,pacotes.DataHoraEntrega) <= 12 then 'AM' else 'PM' end CicloPM,
    case when DATEPART(hh,pacotes.DataHoraEntrega) <= 11 then 'Manhã' 
     when DATEPART(hh,pacotes.DataHoraEntrega) between 12 and 17 then 'Tarde' 
     when DATEPART(hh,pacotes.DataHoraEntrega) between 18 and 23 then 'Noite' 
    else 'PM' end Turno,
	pacotes.Latitude,
	pacotes.Longitude
	,'LM' as Operacao


from
	(
        -- select * from tb_spe_pacotes_v4 with(nolock)
        -- union 
        select * from tb_spe_pacotes_v5 with(nolock) 
     ) pacotes 
	left join tb_spe_motoristas m with(nolock) on pacotes.IdMotorista = m.IdMotorista and pacotes.IdTransportadora = m.IdTransportadora
	left join tb_ml_traducoes t1 with(nolock) on pacotes.StatusEntrega = t1.tds_vl_json and t1.tds_nm_tabela = 'tb_spe_pacotes' and t1.tds_nm_campo = 'StatusEntrega'
	left join tb_ml_traducoes t2 with(nolock) on pacotes.SubStatus = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_spe_pacotes' and t2.tds_nm_campo = 'SubStatus'
	
	 join (
                -- select  * from  tb_spe_rotas_v4 WITH(NOLOCK)
                -- UNION ALL
                select  Id
                ,CodigoRota
                ,IdTransportadora
                ,DataReferencia
                ,DataHoraInicio
                ,DataHoraFim
                ,DataHoraColeta
                ,IdStation
                ,IdMotorista
                ,IdStatus
                ,DataAtualizacao
                ,Excluido
                ,TotalPacotes
                ,PacotesEntregues
                ,PacotesNaoEntregue
                ,PacotesPendentes
                ,DataUltimaEntrega
                ,KmColetado
                ,LinkMapa
                ,TipoVeiculo
                ,DataHoraCarga
                ,Paradas
                ,CidadeReferencia
                ,DistanciaTotal
                ,UsuarioIrisys
                ,KmApp
                ,LinkMapaApp
                ,QuantidadeApontamento
                ,LinkAppInterno
                ,Apuracao
                ,UsouAPP
                from  tb_spe_rotas_v5 WITH(NOLOCK)
                -- where id = 2072

     )  rotas on pacotes.IdTransportadora = rotas.IdTransportadora 
											and pacotes.CodigoRota = rotas.CodigoRota
											--and pacotes.DataReferencia = rotas.DataReferencia
											and rotas.Excluido = 0

where 1=1
    and pacotes.DataReferencia >= DATEADD(m,-2,getdate())
	--(m.Ativo = 1 or rotas.DataReferencia < m.DataInativo)
	and pacotes.Excluido = 0
	and isnull(pacotes.SubStatus,'') <> 'transferred'
    --and  rotas.idmotorista > 0
    and (TotalPacotes > 0)


	--and rotas.CodigoRota = 'AT202406031ZXY0'



	--select * from tb_ml_traducoes
	--where tds_nm_tabela = 'tb_spe_pacotes'
	--and tds_nm_campo = 'SubStatus'

	--and pacotes.DataReferencia = '2024-06-18'
    -- and pacotes.StatusEntrega <> 'Assigned'


	union all


	select distinct
    rotas.Id IdRotaInterno,
    rotas.CodigoRota,
    pacotes.IdTransportadora,
    pacotes.CodigoPacote,
    cast(pacotes.DataCriacaoPacote as date) as DataReferencia,
    pacotes.StatusPacote as StatusEntrega,
    null as SubStatus,
    pacotes.DataHoraEvento as DataHoraEntrega,
    pacotes.DataAtualizacao,
    null as URLImagem,
    pacotes.StatusPacote as StatusEntregaShopee,
    null as SubStatusShopee,
    null as CEP,
    pacotes.StatusPacote as StatusPacote,
    case when DATEPART(hh,pacotes.DataHoraEvento) <= 12 then 'AM' else 'PM' end CicloPM,
    case when DATEPART(hh,pacotes.DataHoraEvento) <= 11 then 'Manhã' 
         when DATEPART(hh,pacotes.DataHoraEvento) between 12 and 17 then 'Tarde' 
         when DATEPART(hh,pacotes.DataHoraEvento) between 18 and 23 then 'Noite' 
    else 'PM' end Turno,
    null as Latitude,
    null as Longitude
	,'FM' as Operacao
from tb_spe_pacotes_fm pacotes with(nolock)
join tb_spe_rotas_v5 rotas with(nolock)
    on pacotes.IdTransportadora = rotas.IdTransportadora
   and cast(pacotes.CodigoRota as varchar) = rotas.CodigoRota
   and rotas.Excluido = 0
where pacotes.Excluido = 0
and cast(pacotes.DataCriacaoPacote as date) >= DATEADD(m,-2,getdate())

union all
select distinct
   rotas.Id IdRotaInterno,
    rotas.CodigoRota,
    pacotes.IdTransportadora,
    pacotes.CodigoPacote,
   null as DataReferencia,
    null as StatusEntrega,
    null as SubStatus,
 null as DataHoraEntrega,
  null as DataAtualizacao,
    null as URLImagem,
   null as StatusEntregaShopee,
    null as SubStatusShopee,
    null as CEP,
null as StatusPacote,
null as ciclopm,
  null Turno,
    null as Latitude,
    null as Longitude,
	'LH' AS Operacao
	from tb_spe_pacotes_lh pacotes
	join tb_spe_rotas_v5 rotas with(nolock)
    on pacotes.IdTransportadora = rotas.IdTransportadora
   and cast(pacotes.CodigoRota as varchar) = rotas.CodigoRota
   and rotas.Excluido = 0


GO
