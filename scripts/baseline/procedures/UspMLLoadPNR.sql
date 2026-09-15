-- ============================================================
-- BASELINE: dbo.UspMLLoadPNR
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLLoadPNR]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLLoadPNR] (
	@Transportadora int,
	@Quinzena varchar(20),
	@JSON VARCHAR(max),
	@DataColeta datetime
)
as
begin

	SET NOCOUNT ON;

	set language 'Português'

	--declare @JSON VARCHAR(max)
	--declare @Transportadora int
	--declare @Quinzena varchar(20)
	--declare @DataColeta datetime
	--declare @DataReferencia datetime

	--select
	--	@JSON = dac_ds_contexto_json,
	--	@Transportadora = dac_cd_transportadora,
	--	@Quinzena = dac_ds_contexto,
	--	@DataColeta = dac_dh_coleta,
	--	@DataReferencia = dac_dh_referencia
	--from
	--	db_Irisys_Json.dbo.tb_dra_coleta
	--where
	--	dac_cd_coleta=64463206

	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'casesList')

	drop table if exists #pnr
	select 
		@Transportadora IdTransportadora
		,@Quinzena Quinzena
		,IdReclamacao
		,case when Data like '%hs%' then cast(getdate() as date) else convert(date,replace(trim(reverse(left(reverse(Data), charindex('|',reverse(Data)) -1))),'de ','') + ' ' + cast(year(getdate()) as varchar(4)),107) end DataReclamacao
		,Motorista
		,ServiceCenter
		,IdEnvio IdPacote
		,cast(replace(Valor,'R$','') as decimal(7, 2)) Valor
		,Status
		,@DataColeta DataColeta
		into #pnr
	from 
		OPENJSON (@JsonList)
		WITH 
		(
			IdReclamacao int '$.id' 
			,Data varchar(1000) '$.config[0].secondary.secondaryValue'
			,Motorista varchar(100) '$.config[1].primary.primaryValue'
			,ServiceCenter varchar(50) '$.config[1].secondary.secondaryValue'
			,IdPacote varchar(max) '$.config[2].primary.primaryValue[0]'
			,Valor varchar(100) '$.config[3].primary.primaryValue'
			,Status varchar(100) '$.caseStatus'
			,JsonEnvio nvarchar(max) '$.config[2].primary.primaryValue[1]' AS JSON
		) as PNR
		CROSS APPLY 
		(
			select
				value Envio
			from
				OPENJSON(PNR.JsonEnvio)
			where
				[Key]='replacements'
		) Pacote
		CROSS APPLY 
		(
			select
				value IdEnvio
			from
				OPENJSON(Pacote.Envio)
			where
				[Key]='1'
		) CodigoPacote


	--ajusta data reclamação que foi gerada com data futura
	update #pnr set DataReclamacao = dateadd(year,-1,DataReclamacao) where DataReclamacao > cast(getdate() as date)
		
	--ajusta data reclmação com base na diferença de dias do pacote caso seja maior que 90, ou seja, caso a relamação tenha sido maior que 90 dias após a data do pacote
	update
		pnr
	set
		DataReclamacao = dateadd(year,year(p.DataReferencia)-year(pnr.DataReclamacao),pnr.DataReclamacao)
	from
		#pnr pnr
		join tb_ml_pacotes p with(nolock) on pnr.IdPacote = p.IdPacote 
												and pnr.IdTransportadora = p.IdTransportadora 
												and p.Excluido = 0 
												and p.Id = (
													select
														max(Id)
													from
														tb_ml_pacotes p2 with(nolock)
													where
														p2.Excluido = 0
														and p.IdPacote = p2.IdPacote
														and p.IdTransportadora = p2.IdTransportadora
													)
	where
		DATEDIFF(day,p.DataReferencia,pnr.DataReclamacao) >= 90


	-- Inclusão de regra para coletar a data de fechamento da PNR de acordo com a alteração do status 
	alter table #pnr add DataFechamento date

	update	pnr_novo
	set		DataFechamento = cast(getdate() as date)
	from	#pnr as pnr_novo
	inner	join tb_ml_pnr as pnr_atual
			on pnr_novo.IdReclamacao = pnr_atual.IdReclamacao and pnr_novo.Idtransportadora = pnr_atual.Idtransportadora
	where	pnr_novo.Status = 'CLOSED_NOT_BILLED' and pnr_atual.Status <> 'CLOSED_NOT_BILLED'

	-- Tratando a Data de Fechamento para os casos que ja chegam em nossa base com o status CLOSED_NOT_BILLED
	update	pnr
	set		DataFechamento = cast(getdate() as date)
	from	#pnr as pnr
	where	pnr.Status = 'CLOSED_NOT_BILLED'




	merge tb_ml_pnr as r
	using #pnr as i ON r.IdTransportadora = i.IdTransportadora and r.IdReclamacao = i.IdReclamacao
	when matched then
	update set
		r.Quinzena = i.Quinzena
		,r.DataReclamacao = i.DataReclamacao
		,r.Motorista = i.Motorista
		,r.ServiceCenter = i.ServiceCenter
		,r.IdPacote = i.IdPacote
		,r.Valor = i.Valor
		,r.Status = i.Status
		,r.DataColeta = i.DataColeta
		,r.DataFechamento = i.DataFechamento
	when not matched by target then 
	insert (
			IdTransportadora
			,IdReclamacao
			,Quinzena
			,DataReclamacao
			,Motorista
			,ServiceCenter
			,IdPacote
			,Valor
			,Status
			,DataColeta
			,DataFechamento
	)
	values (
		i.IdTransportadora
		,i.IdReclamacao
		,i.Quinzena
		,i.DataReclamacao
		,i.Motorista
		,i.ServiceCenter
		,i.IdPacote
		,i.Valor
		,i.Status
		,i.DataColeta
		,i.DataFechamento
	);

	
end
GO
