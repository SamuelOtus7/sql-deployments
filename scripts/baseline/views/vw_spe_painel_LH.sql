-- ============================================================
-- BASELINE: dbo.vw_spe_painel_LH
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_spe_painel_LH]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_spe_painel_LH]
 as 
 
SELECT distinct
    r.CodigoRota,
    r.IdTransportadora,
    r.DataReferencia,
    r.DataHoraInicio,
    r.DataHoraFim,
    r.DataHoraColeta,
    r.IdStation,
    r.IdMotorista,
    r.IdStatus,
    r.DataAtualizacao,
    r.Excluido,
    r.TotalPacotes,
    r.PacotesEntregues,
    r.PacotesNaoEntregue,
    r.PacotesPendentes,
    r.DataUltimaEntrega,
    r.KmColetado,
    r.LinkMapa,
    r.TipoVeiculo,
    r.DataHoraCarga,
    r.Paradas,
    r.CidadeReferencia,
    r.DistanciaTotal,
    r.UsuarioIrisys,
    r.KmApp,
    r.LinkMapaApp,
    r.QuantidadeApontamento,
    r.LinkAppInterno,
    r.Apuracao,
    r.UsouAPP,
    r.NomeHub,
    r.Motorista,
    r.placa,
    r.CidadeDistante,
    r.KmPacotes,
    r.LinkMapaPacotes,
    r.TipoOperacao,

    p.IdTransportadora AS IdTransportadoraPacote,
    p.CodigoRota      AS CodigoRotaPacote,
    p.CodigoPacote,
    p.StationId       AS StationIdPacote


from tb_spe_rotas_v5 R
inner join  tb_spe_pacotes_lh p on r.CODIGOROTA = p.CODIGOROTA AND p.IDTRANSPORTADORA = r.IDTRANSPORTADORA
 
where tipooperacao = 'LH'
and excluido = 0
GO
