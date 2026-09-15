-- ============================================================
-- BASELINE: dbo.tb_ssrs_spe_monitoramento
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ssrs_spe_monitoramento]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ssrs_spe_monitoramento](
	[CodMonitoramento] [int] IDENTITY(1,1) NOT NULL,
	[IdTransportadora] [int] NULL,
	[NomeMotorista] [varchar](100) NULL,
	[ServiceCenter] [varchar](100) NULL,
	[IdRota] [varchar](100) NULL,
	[UltimaEntrega] [varchar](100) NULL,
	[TotalPacotes] [int] NULL,
	[PacotesEntregues] [int] NULL,
	[PacotesPendentes] [int] NULL,
	[Insucesso] [int] NULL,
	[PacotesTransferidos] [int] NULL,
	[Reclamacoes] [int] NULL,
	[RotaFinalizada] [int] NULL,
	[TotalRotas] [int] NULL,
	[RotaEmCurso] [int] NULL,
	[Progresso] [float] NULL,
	[DataHoraInicio] [datetime] NULL,
	[NomeHub] [varchar](100) NULL,
	[Hub] [varchar](100) NULL,
	[PacotesNaoEntregue] [int] NULL,
	[MediaPacotesPorHora] [float] NULL,
	[TempoTotalRotaHoras] [numeric](18, 0) NULL,
	[HorarioInicioRota] [nvarchar](4000) NULL,
	[DataReferencia] [date] NULL,
	[DataHoraDesignacaoRota] [datetime] NULL
) ON [PRIMARY]
GO
