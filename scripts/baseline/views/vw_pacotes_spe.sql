-- ============================================================
-- BASELINE: dbo.vw_pacotes_spe
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_spe]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_pacotes_spe]
as
select
	rotas.Id IdRotaInterno,
	pacotes.IdStation,
	station.NomeStation,
	pacotes.IdTransportadora,
	motoristas.NomeMotorista Motorista,
	pacotes.CodigoPacote,
	pacotes.DataReferencia,
	t1.tds_ds_traducao StatusEntrega,
	t2.tds_ds_traducao SubStatus,
	pacotes.DataHoraEntrega,
	pacotes.DataAtualizacao
from
	tb_spe_pacotes pacotes with(nolock)
	join tb_spe_motoristas motoristas with(nolock) on pacotes.IdMotorista = motoristas.IdMotorista
	left join tb_spe_station station with(nolock) on pacotes.IdStation = station.IdStation
	left join tb_ml_traducoes t1 with(nolock) on pacotes.StatusEntrega = t1.tds_vl_json and t1.tds_nm_tabela = 'tb_spe_pacotes' and t1.tds_nm_campo = 'StatusEntrega'
	left join tb_ml_traducoes t2 with(nolock) on pacotes.SubStatus = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_spe_pacotes' and t2.tds_nm_campo = 'SubStatus'
	join tb_spe_rotas rotas with(nolock) on pacotes.IdTransportadora = rotas.IdTransportadora 
											and pacotes.IdMotorista = rotas.IdMotorista
											and pacotes.DataReferencia = rotas.DataReferencia
where
	(motoristas.Ativo = 1 or rotas.DataReferencia < motoristas.DataInativo)
GO
