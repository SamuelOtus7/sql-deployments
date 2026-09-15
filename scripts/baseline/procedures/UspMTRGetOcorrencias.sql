-- ============================================================
-- BASELINE: dbo.UspMTRGetOcorrencias
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMTRGetOcorrencias]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMTRGetOcorrencias]
as 
begin

drop table if exists #ocorrencias
select a.id,
	   a.tenantId as IdTransportadora,
	   a.createdAt as DataHoraColeta,
	   base.*
into #ocorrencias
from tb_mtr_webhook a
	cross apply (
			select distinct
			 case when isnumeric(CodigoOcorrencia) = 1 then CodigoOcorrencia else 0 end as CodigoOcorrencia
			,NumeroPedido
			,NumeroRemessa
			,DescricaoOcorrencia
			,convert(datetime, DataHoraOcorrencia, 103) DataHoraOcorrencia
			,PlacaVeiculo
			,CpfMotorista
			,CnpjCpfDestinatario
			,Iccid
			,Observacao
			,getdate() DataAtualizacao
			,0 Excluido
		from OPENJSON (a.jsonData)
		with
		(
			 CodigoOcorrencia varchar(30) '$.codOcorrencia' 
			,NumeroPedido bigint '$.numeroPedido' 
			,NumeroRemessa varchar(30) '$.numeroRemessa'
			,DescricaoOcorrencia varchar(100) '$.descOcorrencia'
			,DataHoraOcorrencia varchar(60) '$.datahoraOcorrencia'
			,PlacaVeiculo varchar(10) '$.placaVeiculo'
			,CpfMotorista varchar(20) '$.cpfMotorista'
			,CnpjCpfDestinatario varchar(20) '$.cnpjCpfDes' 
			,Iccid varchar(30) '$.iccid' 
			,Observacao varchar(100) '$.obsMov'
		)
	) as base
where a.webhook = 'ocorrencias_tim'
	  and processingStatus is null
	  
merge tb_mtr_ocorrencias as o
	using #ocorrencias as i ON o.id = i.id
	when matched then
	update set
		 o.NumeroRemessa = i.NumeroRemessa
		,o.DescricaoOcorrencia = i.DescricaoOcorrencia
		,o.DataHoraOcorrencia = i.DataHoraOcorrencia
		,o.PlacaVeiculo = i.PlacaVeiculo
		,o.CpfMotorista = i.CpfMotorista
		,o.CnpjCpfDestinatario = i.CnpjCpfDestinatario
		,o.Iccid = i.Iccid
		,o.Observacao = i.Observacao
		,o.DataHoraColeta = i.DataHoraColeta
		,o.DataAtualizacao = i.DataAtualizacao
		,o.Excluido = i.Excluido

	when not matched by target then 
	insert (
			Id
			,IdTransportadora
			,CodigoOcorrencia
			,NumeroPedido
			,NumeroRemessa
			,DescricaoOcorrencia
			,DataHoraOcorrencia
			,PlacaVeiculo
			,CpfMotorista
			,CnpjCpfDestinatario
			,Iccid
			,Observacao
			,DataHoraColeta
			,DataAtualizacao
			,Excluido
	)
	values (
			i.id
			,i.IdTransportadora
			,i.CodigoOcorrencia
			,i.NumeroPedido
			,i.NumeroRemessa
			,i.DescricaoOcorrencia
			,i.DataHoraOcorrencia
			,i.PlacaVeiculo
			,i.CpfMotorista
			,i.CnpjCpfDestinatario
			,i.Iccid
			,i.Observacao
			,i.DataHoraColeta
			,i.DataAtualizacao
			,i.Excluido
);

update webhook
set processingStatus = 1, processingDatetime = getdate(), processingResult = 'sucess'
from tb_mtr_webhook webhook
	join #ocorrencias as ocorrencias on webhook.id = ocorrencias.id


/*
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	drop table if exists #coleta_ocorrencias
	select
		id
		,tenantId
		,jsonData
		,createdAt
		,verifica_json
		,row_number() over (order by id ) linha
		into #coleta_ocorrencias
	from
		(
		SELECT 
			TOP 1000 id, tenantId, jsonData, createdAt,
			case when left(jsonData,1) in ('{','[') and jsonData <> '[]' then 1 else 0 end verifica_json
        FROM 
			tb_mtr_webhook WITH (ROWLOCK, READPAST, UPDLOCK)
		WHERE 
			processingStatus is null
			and webhook = 'ocorrencias_tim'
		ORDER BY 
			id
		) Q


	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @Transportadora int
	declare @DataColeta datetime
	declare @VerificaJson bit
	

	declare @inicio int = 1
	declare @fim int = (select max(linha) from #coleta_ocorrencias)
	while @inicio <= @fim 
	begin 
		
		declare @ErrorMessage nvarchar(4000) = null;
		declare @StatusExecucao varchar(100) = 'sucesso'
		declare @Status bit = 1

		select
			@QueueID = Q.id, 
			@Json = Q.jsonData,
			@Transportadora = Q.tenantId,
			@DataColeta = Q.createdAt,
			@VerificaJson = Q.verifica_json
		FROM 
			#coleta_ocorrencias Q
		where 
			linha = @inicio 

		if @VerificaJson = 1
		begin
			
			begin try
				exec UspMTRLoadOcorrencias @Json, @Transportadora, @DataColeta
			end try
			begin catch
				SET @ErrorMessage = ERROR_MESSAGE()
				set @StatusExecucao = 'erro'
				set @Status = 0
			end catch
		end
		
		update 
			t
		set 
			processingDatetime = GETDATE(), 
			processingStatus = @Status,
			processingResult = @StatusExecucao,
			processingMessage = @ErrorMessage
		from
			tb_mtr_webhook t
			join #coleta_ocorrencias b on t.id = b.id
		where 
			b.linha  = @inicio	
		
		set @inicio = @inicio + 1

	end
*/


end
GO
