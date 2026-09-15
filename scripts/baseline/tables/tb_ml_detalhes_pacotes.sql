-- ============================================================
-- BASELINE: dbo.tb_ml_detalhes_pacotes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_detalhes_pacotes]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_detalhes_pacotes](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdPacote] [bigint] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[Status] [varchar](150) NULL,
	[SubStatus] [varchar](150) NULL,
	[InicioPromessaEntrega] [date] NULL,
	[FimPromessaEntrega] [date] NULL,
	[Altura] [decimal](18, 9) NULL,
	[Largura] [decimal](18, 9) NULL,
	[Comprimento] [decimal](18, 9) NULL,
	[Peso] [decimal](18, 9) NULL,
	[Volume] [decimal](18, 9) NULL,
	[Origem] [varchar](150) NULL,
	[NomeComprador] [varchar](250) NULL,
	[TelefoneComprador] [varchar](30) NULL,
	[Endereco] [varchar](250) NULL,
	[Rua] [varchar](250) NULL,
	[Numero] [varchar](30) NULL,
	[Latitude] [decimal](18, 9) NULL,
	[Longitude] [decimal](18, 9) NULL,
	[Complemento] [varchar](250) NULL,
	[TipoEndereco] [varchar](30) NULL,
	[Cidade] [varchar](150) NULL,
	[Estado] [varchar](30) NULL,
	[CEP] [int] NULL,
	[TipoRecebedor] [varchar](50) NULL,
	[NomeRecebedor] [varchar](250) NULL,
	[TipoDocumento] [varchar](50) NULL,
	[Documento] [varchar](50) NULL,
	[NomeContato1] [varchar](150) NULL,
	[TelefoneContato1] [varchar](150) NULL,
	[EmailContato1] [varchar](150) NULL,
	[NomeContato2] [varchar](150) NULL,
	[TelefoneContato2] [varchar](150) NULL,
	[EmailContato2] [varchar](150) NULL,
	[NomeContato3] [varchar](150) NULL,
	[TelefoneContato3] [varchar](150) NULL,
	[EmailContato3] [varchar](150) NULL,
	[SituacaoDasColetas] [varchar](50) NULL,
 CONSTRAINT [PK_tb_ml_detalhes_pacotes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_ml_detalhes_pacotes] UNIQUE NONCLUSTERED 
(
	[IdPacote] ASC,
	[IdTransportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
