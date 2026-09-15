-- ============================================================
-- BASELINE: dbo.UspMLAtualizaRotasPlayTelematics
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaRotasPlayTelematics]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLAtualizaRotasPlayTelematics] (
	@DataReferencia date
)
as
begin
select @@VERSION
/*
	select 
		* 
		into #rotas
	from 
		[PLAYTELEMATICS].db_RodaCoop.dbo.tb_ml_rotas 
	where 
		datacoleta=@DataReferencia

	insert into tb_ml_rotas (IdRota, DataReferencia, DataHoraColeta, ServiceCenter, OrigemSaida, TipoOrigemSaida, Tipo, TipoRota, StatusRota, SubStatusRota, TipoEntrega, IdTransportadora, DataHoraInicio, DataHoraFim, TotalPacotes, PacotesEntregues, PacotesNaoEntregue, PacotesPendentes, PacotesEntreguesForaAreaEntrega, PacotesTransferidos, PacotesRecebidos, TotalSacas, QuantidadeAmbulancia, StatusPrazo, NomeMotorista, NivelExperienciaMotorista, MotoristaArriscado, QuantidadeReclamacoesMotorista, TaxaDeContatoMotorista, IdNivelMotorista, NivelMotorista, QuantidadePacotesTransportados, PercentualEntregasBemSucedidas, PercentualEntregasSemRelamacaoes, PossuiAjudante, TipoVeiculo, Placa, TempoPlanejadoMinutos, PercentualProgresso, KmTotal, TempoEmRota, TempoChegadaAreaEntrega, TempoAreaEntrega, TempoRetornoCentroDistribuicao, TempoInativo, DataAtualizacao, Excluido, QuantidadePontos, QuantidadeParadas, DataUltimaAtualizacaoPacote, DataPrimeiraEntrega, LinkMapa, StatusPrimeiraEntrega, StatusSegundaEntrega, QuantidadeReclamacoes, KmColetado, DataUltimaEntrega, KmColetadoApp, LinkMapaApp, KmColetadoGeo, LinkMapaGeo, Cidades, CidadeReferencia)
	select
		r.IdRota
		,r.DataColeta DataReferencia
		,r.DataHoraColeta
		,r.ServiceCenter
		,'' OrigemSaida --montar de para para saber se é xpt
		,null TipoOrigemSaida
		,'' Tipo
		,r.TipoRota
		,isnull(t.tds_vl_json,r.StatusRota) StatusRota
		,'' SubStatusRota
		,'' TipoEntrega
		,59903397 IdTransportadora
		,r.DataHoraColeta DataHoraInicio --considerando este campo pois não busca esta informação na play
		,null DataHoraFim
		,isnull(r.Entregues,0) + isnull(r.NaoEntregue,0) + isnull(r.Pendentes,0) TotalPacotes
		,isnull(r.Entregues,0) PacotesEntregues
		,isnull(r.NaoEntregue,0) PacotesNaoEntregue
		,isnull(r.Pendentes,0) PacotesPendentes
		,0 PacotesEntreguesForaAreaEntrega
		,0 PacotesTransferidos
		,0 PacotesRecebidos
		,0 TotalSacas
		,isnull(r.QuantidadeAmbulancia,0) QuantidadeAmbulancia
		,r.StatusPrazo
		,r.NomeMotorista NomeMotorista
		,isnull(t2.tds_vl_json,r.NivelMotorista) NivelExperienciaMotorista
		,0 MotoristaArriscado
		,r.QuantidadeReclamacoesMotorista
		,null TaxaDeContatoMotorista
		,loyalty_id IdNivelMotorista
		,loyalty_name NivelMotorista
		,case when charindex(' p', r.QuantidadePacotesTransportados) > 0 then cast(replace(left(r.QuantidadePacotesTransportados,charindex(' p', r.QuantidadePacotesTransportados)-1),'.','') as int) else null end QuantidadePacotesTransportados
		,case when charindex('%', r.PercentualEntregasBemSucedidas) > 0 then cast(cast(replace(left(r.PercentualEntregasBemSucedidas,charindex('%', r.PercentualEntregasBemSucedidas)-1),',','.') as decimal(5,2)) / 100 as decimal(5,4)) else null end PercentualEntregasBemSucedidas
		,case when charindex('%', r.PercentualEntregasSemRelamacaoes) > 0 then cast(cast(replace(left(r.PercentualEntregasSemRelamacaoes,charindex('%', r.PercentualEntregasSemRelamacaoes)-1),',','.') as decimal(5,2)) / 100 as decimal(5,4)) else null end PercentualEntregasSemRelamacaoe
		,0 PossuiAjudante
		,replace(replace(replace(replace(replace(r.TipoVeiculo, 'UtilitÃ¡rio', 'Utilitário'), 'Ãºnica', 'única'), 'VeÃ­culo', 'Veículo'), ' â€“ ', ' – '),'MÃ©dio', 'Médio') TipoVeiculo
		,r.Placa
		,null TempoPlanejadoMinutos
		,cast(cast(replace(r.PercentualProgresso,',','.') as decimal(5,2)) / 100 as decimal(5,4)) PercentualProgresso
		,cast(r.KmTotal as decimal(8,4)) KmTotal
		,TotalOrh TempoEmRota
		,TotalStemOut TempoChegadaAreaEntrega
		,TotalOzh TempoAreaEntrega
		,0 TempoRetornoCentroDistribuicao
		,null TempoInativo
		,getdate() DataAtualizacao
		,0 Excluido
		,0 QuantidadePontos
		,0 QuantidadeParadas
		,null DataUltimaAtualizacaoPacote
		,null DataPrimeiraEntrega
		,null LinkMapa
		,null StatusPrimeiraEntrega
		,null StatusSegundaEntrega
		,0 QuantidadeReclamacoes
		,0 KmColetado
		,null DataUltimaEntrega
		,null KmColetadoApp
		,null LinkMapaApp
		,null KmColetadoGeo
		,null LinkMapaGeo
		,null Cidades
		,null CidadeReferencia
	from
		#rotas r
		left join tb_ml_traducoes t on r.StatusRota = t.tds_ds_traducao collate Latin1_General_CI_AS and t.tds_nm_tabela = 'tb_ml_rotas' and t.tds_nm_campo = 'StatusRota'
		left join tb_ml_traducoes t2 on r.NivelMotorista = t2.tds_ds_traducao collate Latin1_General_CI_AS and t2.tds_nm_tabela = 'tb_ml_rotas' and t2.tds_nm_campo = 'NivelExperienciaMotorista'
		left join tb_ml_rotas r2 on r.IdRota = r2.IdRota and r2.DataReferencia = r.DataColeta and r2.IdTransportadora = 59903397
	where
		r2.idrota is null

	
	select 
		* 
		into #pacotes
	from 
		[PLAYTELEMATICS].db_RodaCoop.dbo.tb_ml_pacotes 
	where 
		datacoleta=@DataReferencia

	insert into tb_ml_pacotes (IdPacote, IdRota, IdTransportadora, DataReferencia, DataHoraColeta, DataHoraEntrega, TipoPacote, Status, SubStatus, StatusEntrega, TipoEndereco, TipoEnderecoPreferencia, IdRotaOrigem, IdRotaDestino, QuantidadeReclamacoes, ForaAreaEntrega, TemVolumoso, NomeEtiqueta, Endereco, IdParada, SequenciaParada, StatusParada, EnderecoParada, TipoEnderecoParada, LatitudeEnderecoParada, LongitudeEnderecoParada, QuantidadePontosParada, DataAtualizacao, Excluido, Cidade)
	select
		p.IdEntrega IdPacote
		,p.IdRota
		,59903397 IdTransportadora
		,p.DataColeta DataReferencia
		,p.DataHoraColeta DataHoraColeta
		,p.DataHoraColeta DataHoraEntrega
		,null TipoPacote
		,null Status
		,isnull(t.tds_vl_json,p.SubStatus) SubStatus
		,isnull(t2.tds_vl_json,p.StatusEntrega) StatusEntrega
		,isnull(t3.tds_vl_json,p.TipoEndereco) TipoEndereco
		,null TipoEnderecoPreferencia
		,p.IdRotaOrigem
		,p.IdRotaDestino
		,p.QuantidadeReclamacoes
		,null ForaAreaEntrega
		,null TemVolumoso
		,null NomeEtiqueta
		,p.Rua Endereco
		,0 IdParada
		,null SequenciaParada
		,'' StatusParada
		,null EnderecoParada
		,null TipoEnderecoParada
		,p.Latitude LatitudeEnderecoParada
		,p.Longitude LongitudeEnderecoParada
		,isnull(p.Pontos,0) QuantidadePontosParada
		,getdate() DataAtualizacao
		,0 Excluido
		,null Cidade
	from
		#pacotes p
		left join tb_ml_traducoes t on p.SubStatus = t.tds_ds_traducao collate Latin1_General_CI_AS and t.tds_nm_tabela = 'tb_ml_pacotes' and t.tds_nm_campo = 'SubStatus'
		left join tb_ml_traducoes t2 on p.StatusEntrega = t2.tds_ds_traducao collate Latin1_General_CI_AS and t2.tds_nm_tabela = 'tb_ml_pacotes' and t2.tds_nm_campo = 'StatusEntrega'
		left join tb_ml_traducoes t3 on p.TipoEndereco = t3.tds_ds_traducao collate Latin1_General_CI_AS and t3.tds_nm_tabela = 'tb_ml_pacotes' and t3.tds_nm_campo = 'TipoEndereco'
		left join tb_ml_pacotes p2 on p.IdRota = p2.IdRota and p.DataColeta = p2.DataReferencia and p.IdEntrega = p2.IdPacote and p2.IdTransportadora = 59903397
	where
		p2.IdPacote is null

end*/

end
GO
