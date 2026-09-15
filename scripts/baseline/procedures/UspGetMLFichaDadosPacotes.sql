-- ============================================================
-- BASELINE: dbo.UspGetMLFichaDadosPacotes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetMLFichaDadosPacotes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGetMLFichaDadosPacotes]
(
	@Transportadora int,
	@Rota varchar(50)
)

as
	declare @IdRota int  = try_cast(@Rota as int)

select 
  IdPacote
 ,DataReferencia
 ,DataHoraColeta
 ,DataHoraEntrega
 ,TipoPacote
 ,Status
 ,SubStatus
 ,StatusEntrega
 ,TipoEndereco
 ,TipoEnderecoPreferencia
 ,'Não' as Transferencia
 ,IdRotaOrigem
 ,'Motorista' as MotoristaRotaOrigem
 ,IdRotaDestino
 ,'Motorista' as MotoristaRotaDestino
 ,QuantidadeReclamacoes
 ,ForaAreaEntrega
 ,TemVolumoso
 ,NomeEtiqueta
 ,Endereco
 ,IdParada
 ,SequenciaParada
 ,StatusParada
 ,EnderecoParada
 ,TipoEnderecoParada
 ,LatitudeEnderecoParada
 ,LongitudeEnderecoParada
 ,QuantidadePontosParada
 ,Cidade
 ,'Não' as Reclamacao
 ,'Não' as PNR

from tb_ml_pacotes as rotas
	inner join tb_clientes as clientes
	on rotas.IdTransportadora = clientes.cli_id_logistics
where 
	--cast(IdRota as varchar(50)) = @Rota
	IdRota = @IdRota
	and clientes.cli_cd_codigo_cliente = @Transportadora

GO
