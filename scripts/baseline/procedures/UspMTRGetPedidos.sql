-- ============================================================
-- BASELINE: dbo.UspMTRGetPedidos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMTRGetPedidos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMTRGetPedidos]
as 
begin

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	drop table if exists #coleta_pedidos
	select
		id
		,tenantId
		,jsonData
		,createdAt
		,verifica_json
		,row_number() over (order by id ) linha
		into #coleta_pedidos
	from
		(
		SELECT 
			TOP 1000 id, tenantId, jsonData, createdAt,
			case when left(jsonData,1) in ('{','[') and jsonData <> '[]' then 1 else 0 end verifica_json
        FROM 
			tb_mtr_webhook WITH (ROWLOCK, READPAST, UPDLOCK)
		WHERE 
			processingStatus is null
			and webhook = 'pedidos_tim'
		ORDER BY 
			id
		) Q


	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @Transportadora int
	declare @DataColeta datetime
	declare @VerificaJson bit
	

	declare @inicio int = 1
	declare @fim int = (select max(linha) from #coleta_pedidos)
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
			#coleta_pedidos Q
		where 
			linha = @inicio 

		if @VerificaJson = 1
		begin
			
			begin try
				exec UspMTRLoadPedidos @Json, @Transportadora, @DataColeta
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
			join #coleta_pedidos b on t.id = b.id
		where 
			b.linha  = @inicio	
		
		set @inicio = @inicio + 1

	end

end
GO
