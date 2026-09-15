-- ============================================================
-- BASELINE: dbo.tb_periodos_espelhos_pagamento
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_periodos_espelhos_pagamento]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_periodos_espelhos_pagamento](
	[pep_cd_periodo] [int] IDENTITY(1,1) NOT NULL,
	[pep_cd_cliente] [int] NOT NULL,
	[pep_cd_cliente_transportadora] [int] NOT NULL,
	[pep_dt_inicio] [datetime] NOT NULL,
	[pep_dt_fim] [datetime] NOT NULL,
	[pep_dh_criacao] [datetime] NOT NULL,
	[pep_in_ativo] [bit] NOT NULL,
	[pep_in_excluido] [bit] NOT NULL,
	[pep_cd_periodo_pagamento] [int] NULL,
	[pep_cd_operacao] [int] NOT NULL,
	[pep_in_calcular_espelho] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[pep_cd_periodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
