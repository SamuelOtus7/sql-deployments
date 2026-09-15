-- ============================================================
-- BASELINE: dbo.UspMLInsereRotasReprocessadas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLInsereRotasReprocessadas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLInsereRotasReprocessadas] as 
--colocar parametros que aceitam nulo
--id da tranpsortada
--data inicio e fim, quando nao passar nenhum data tras apenas hoje e ontem.


declare @dataini date  = getdate()-1
declare @datafim date  = getdate()

	drop table if exists #rotas
	select
	 a.cmr_ds_json
	,a.cmr_cd_rota
	,cmr_dh_referencia as Data
	,a.cmr_cd_transportadora
	into #rotas 
	from
		db_Irisys_Json.dbo.tb_ml_coleta_rotas as a
	inner join (
							select  cmr_cd_rota, Data
							from (
									select cmr_cd_rota, cmr_cd_transportadora, max(cmr_dh_referencia) as Data
									from db_Irisys_Json.dbo.tb_ml_coleta_rotas as rotas
									where cmr_in_processado = 1
									and cmr_dh_referencia between @dataini and @datafim
									--and cmr_cd_transportadora = 1387994348
									group by cmr_cd_rota, cmr_cd_transportadora
								)as coletadas
								join tb_clientes as clientes on coletadas.cmr_cd_transportadora = clientes.cli_id_logistics
								
								left join tb_ml_rotas as processadas
								on coletadas.cmr_cd_rota = processadas.IdRota
								and coletadas.cmr_cd_transportadora = processadas.IdTransportadora
							where processadas.IdRota is null 
		) as b
	on a.cmr_cd_rota = b.cmr_cd_rota
	and a.cmr_dh_referencia = b.Data

	where  a.cmr_dh_referencia between @dataini and @datafim

	drop table if exists #rota_svc
	SELECT 
		IdRota
		,cmr_cd_transportadora as IdTransportadora 
		,ServiceCenter
		,OrigemSaida
		,NomeMotorista
		,Placa
		,Data
		,TipoVeiculo
		,dateadd(second,((cast(DataHoraInicio as bigint))) - 10800,'1970-01-01') DataHoraInicio

	into #rota_svc

	FROM #rotas aux
	cross apply openjson (aux.cmr_ds_json, '$')
		WITH (
			IdRota bigint '$.id'	
			,ServiceCenter varchar(15) '$.serviceCenterId'
			,NomeMotorista varchar(100) '$.driver.driverName'
			,Placa varchar(10) '$.license'
			,DataHoraInicio bigint '$.initDate'
			,OrigemSaida varchar(60) '$.destinationFacility.destinationFacilityId'
			,TipoVeiculo varchar(40) '$.vehicleType'
		)


	MERGE INTO tb_ml_rotas AS target
USING (
    SELECT
        a.IdRota,
        a.DataReferencia,
        MIN(a.DataHoraColeta) AS DataHoraColeta,
        rsvc.ServiceCenter,
        ISNULL(rsvc.OrigemSaida, rsvc.ServiceCenter) AS OrigemSaida,
        'close' AS StatusRota,
        '' AS TipoEntrega,
        a.IdTransportadora,
        rsvc.DataHoraInicio,
        COUNT(1) AS TotalPacotes,
        SUM(CASE WHEN StatusEntrega = 'delivered' THEN 1 ELSE 0 END) AS PacotesEntregues,
        SUM(CASE WHEN StatusEntrega = 'not_delivered' AND ISNULL(SubStatus,'') <> 'transferred' THEN 1 ELSE 0 END) AS PacotesNaoEntregue,
        SUM(CASE WHEN StatusEntrega = 'pending' THEN 1 ELSE 0 END) AS PacotesPendentes,
        0 AS PacotesEntreguesForaAreaEntrega,
        SUM(CASE WHEN StatusEntrega = 'not_delivered' AND ISNULL(SubStatus,'') = 'transferred' THEN 1 ELSE 0 END) AS PacotesTransferidos,
        0 AS PacotesRecebidos,
        0 AS TotalSacas,
        ISNULL(rsvc.NomeMotorista, c.dhr_ds_nome_motorista) AS NomeMotorista,
        0 AS MotoristaArriscado,
        0 AS PossuiAjudante,
        rsvc.Placa,
        0 AS Excluido,
        0 AS TempoEmRota,
        0 AS TempoChegadaAreaEntrega,
        0 AS TempoAreaEntrega,
        0 AS TempoRetornoCentroDistribuicao,
        0 AS QuantidadePontos,
        0 AS QuantidadeParadas,
        0 AS QuantidadeReclamacoes,
        0 AS KmColetado,
        GETDATE() AS DataAtualizacao,
        rsvc.TipoVeiculo,
        '-' AS TipoRota
    FROM tb_ml_pacotes AS a WITH (NOLOCK)
    LEFT JOIN tb_ml_rotas AS r WITH (NOLOCK)
        ON a.IdRota = r.IdRota
        AND a.DataReferencia = r.DataReferencia
        AND a.IdTransportadora = r.IdTransportadora
        AND r.StatusRota <> 'planned'
    INNER JOIN #rota_svc AS rsvc
        ON a.IdRota = rsvc.IdRota
        AND a.IdTransportadora = rsvc.IdTransportadora
        AND a.DataReferencia = rsvc.Data
    INNER JOIN tb_dra_historico_rotas c
        ON a.IdRota = c.dhr_nr_rota
    WHERE a.DataReferencia BETWEEN @dataini AND @datafim
      --AND a.IdRota = 339356319
      AND a.Excluido = 0
      --AND r.IdRota IS NULL
    GROUP BY
        a.IdTransportadora,
        a.IdRota,
        a.DataReferencia,
        rsvc.ServiceCenter,
        rsvc.NomeMotorista,
        rsvc.Placa,
        rsvc.DataHoraInicio,
        rsvc.OrigemSaida,
        rsvc.TipoVeiculo,
        c.dhr_ds_nome_motorista
) AS source
ON target.IdRota = source.IdRota
   AND target.DataReferencia = source.DataReferencia
   AND target.IdTransportadora = source.IdTransportadora

WHEN MATCHED THEN
    UPDATE SET
        target.DataHoraColeta = source.DataHoraColeta,
        target.ServiceCenter = source.ServiceCenter,
        target.OrigemSaida = source.OrigemSaida,
        target.StatusRota = source.StatusRota,
        target.TipoEntrega = source.TipoEntrega,
        target.DataHoraInicio = source.DataHoraInicio,
        target.TotalPacotes = source.TotalPacotes,
        target.PacotesEntregues = source.PacotesEntregues,
        target.PacotesNaoEntregue = source.PacotesNaoEntregue,
        target.PacotesPendentes = source.PacotesPendentes,
        target.PacotesEntreguesForaAreaEntrega = source.PacotesEntreguesForaAreaEntrega,
        target.PacotesTransferidos = source.PacotesTransferidos,
        target.PacotesRecebidos = source.PacotesRecebidos,
        target.TotalSacas = source.TotalSacas,
        target.NomeMotorista = source.NomeMotorista,
        target.MotoristaArriscado = source.MotoristaArriscado,
        target.PossuiAjudante = source.PossuiAjudante,
        target.Placa = source.Placa,
        target.Excluido = source.Excluido,
        target.TempoEmRota = source.TempoEmRota,
        target.TempoChegadaAreaEntrega = source.TempoChegadaAreaEntrega,
        target.TempoAreaEntrega = source.TempoAreaEntrega,
        target.TempoRetornoCentroDistribuicao = source.TempoRetornoCentroDistribuicao,
        target.QuantidadePontos = source.QuantidadePontos,
        target.QuantidadeParadas = source.QuantidadeParadas,
        target.QuantidadeReclamacoes = source.QuantidadeReclamacoes,
        target.KmColetado = source.KmColetado,
        target.DataAtualizacao = source.DataAtualizacao,
        target.TipoVeiculo = source.TipoVeiculo,
        target.TipoRota = source.TipoRota

WHEN NOT MATCHED THEN
    INSERT (
        IdRota, DataReferencia, DataHoraColeta, ServiceCenter, OrigemSaida, StatusRota,
        TipoEntrega, IdTransportadora, DataHoraInicio, TotalPacotes, PacotesEntregues,
        PacotesNaoEntregue, PacotesPendentes, PacotesEntreguesForaAreaEntrega,
        PacotesTransferidos, PacotesRecebidos, TotalSacas, NomeMotorista, MotoristaArriscado,
        PossuiAjudante, Placa, Excluido, TempoEmRota, TempoChegadaAreaEntrega, TempoAreaEntrega,
        TempoRetornoCentroDistribuicao, QuantidadePontos, QuantidadeParadas, QuantidadeReclamacoes,
        KmColetado, DataAtualizacao, TipoVeiculo, TipoRota
    )
    VALUES (
        source.IdRota, source.DataReferencia, source.DataHoraColeta, source.ServiceCenter, source.OrigemSaida, source.StatusRota,
        source.TipoEntrega, source.IdTransportadora, source.DataHoraInicio, source.TotalPacotes, source.PacotesEntregues,
        source.PacotesNaoEntregue, source.PacotesPendentes, source.PacotesEntreguesForaAreaEntrega,
        source.PacotesTransferidos, source.PacotesRecebidos, source.TotalSacas, source.NomeMotorista, source.MotoristaArriscado,
        source.PossuiAjudante, source.Placa, source.Excluido, source.TempoEmRota, source.TempoChegadaAreaEntrega, source.TempoAreaEntrega,
        source.TempoRetornoCentroDistribuicao, source.QuantidadePontos, source.QuantidadeParadas, source.QuantidadeReclamacoes,
        source.KmColetado, source.DataAtualizacao, source.TipoVeiculo, source.TipoRota
    );


--calcula as paradas
update rotas
	set quantidadeparadas = base.paradas

from tb_ml_rotas as rotas
		
inner join #rota_svc as rsvc
on  rotas.IdRota = rsvc.IdRota
and rotas.IdTransportadora = rsvc.IdTransportadora
and rotas.DataReferencia = rsvc.Data

join (	
	select idrota, count(distinct idparada) as paradas
	from tb_ml_pacotes
	where excluido = 0 
	--and idtransportadora = 1788092343 
	and datareferencia between @dataini and @datafim
	   and (SubStatus not in('transferred')
			   or SubStatus not in('missing') and statusparada = 'incomplete')
	and excluido = 0
	group by idrota

) as base
on rotas.idrota = base.idrota

where 1=1 
--and rotas.idtransportadora = 1788092343 
and rotas.datareferencia  between @dataini and @datafim
and rotas.QuantidadeParadas = 0
GO
