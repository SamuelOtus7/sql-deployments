-- ============================================================
-- BASELINE: dbo.UspGetSPEFichaDadosPacotes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetSPEFichaDadosPacotes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO
CREATE procedure [dbo].[UspGetSPEFichaDadosPacotes]
(
	@Transportadora int,
	@Rota varchar(50)
)

as

select 
     codigopacote
    ,DataReferencia
    ,DataHoraColeta
    ,DataHoraEntrega
    ,StatusEntrega as [StatusEntrega]
    ,SubStatus as [SubStatusEntrega]
    ,'motorista' as Motorista
    ,'motorista' as MotoristaRotaDestino
    ,RecebidoPor
    ,cep
    ,Latitude
    ,Longitude
    ,StatusPacote

    from tb_spe_pacotes_v4 as rotas

inner join tb_clientes as clientes
on rotas.IdTransportadora = clientes.cli_id_logistics

where cast(CodigoPacote as varchar(50)) = @Rota
	  and clientes.cli_cd_codigo_cliente = @Transportadora


GO
