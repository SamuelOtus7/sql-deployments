-- ============================================================
-- BASELINE: dbo.UspSSRSLogaEnvioRelatorio
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSSRSLogaEnvioRelatorio]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspSSRSLogaEnvioRelatorio]
(
    @IdEnvio int,
    @IdRelatorio int,
    @IdTransportadora int,
    @Status varchar(100),
    @MensagemErro varchar(250) = '',
    @Parametro1  varchar(2250) = '',
    @Parametro2  varchar(2250) = '',
    @Parametro3  varchar(2250) = '',
    @Parametro4  varchar(2250) = '',
    @Parametro5  varchar(2250) = '',
    @Parametro6  varchar(2250) = '',
    @Parametro7  varchar(2250) = '',
    @Parametro8  varchar(2250) = '',
    @Parametro9  varchar(2250) = '',
    @Parametro10 varchar(250) = ''
)

AS BEGIN

insert into tb_log_envios_relatorios
values (
    @IdEnvio,
        @IdRelatorio,
    @IdTransportadora,
    @Parametro1,
    @Parametro2,
    @Parametro3,
    @Parametro4,
    @Parametro5,
    @Parametro6,
    @Parametro7,
    @Parametro8,
    @Parametro9,
    @Parametro10,
    getdate(),
    @Status,
    @MensagemErro,
    1
) 

END
GO
