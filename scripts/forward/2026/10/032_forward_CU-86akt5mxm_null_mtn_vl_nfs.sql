/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akt5mxm
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-05
  Descrição    : Corrige erro Msg 515 (Cannot insert the value NULL into column
                 'mtn_vl_nfs', table 'tb_pag_espelhos') na execucao de
                 UspFinGeraPagamento, disparado por descontos importados em
                 tb_fin_prefatura_descontos com a coluna 'total' NULL
                 (ex.: 'Pnr Packages Penalty', 'Lost Packages Penalty').
                 O NULL propagava para tb_pgto_periodo_rota.ppr_vl_total e, no
                 comando de atualizacao do espelho, SUM(ppr_vl_total) retornava
                 NULL para espelhos
                 compostos 100% por rotas sem valor -> violacao de NOT NULL.
                 Alteracoes (blocos cliente 49 e clientes 11/47):
                   1. coalesce ISNULL(total,0) na geracao de ppr_vl_total e
                      ppr_vl_desconto das temp tables de desconto;
                   2. coalesce ISNULL(total,0) no UPDATE de mtn_vl_nfs.
                 Penalidades sem valor passam a ser registradas como 0,
                 preservando a observacao no espelho para contestacao.
  Rollback     : scripts/rollback/2026/10/032_rollback_CU-86akt5mxm_null_mtn_vl_nfs.sql
  Objetos      : CREATE OR ALTER PROCEDURE dbo.UspFinGeraDescontoPagamento
  Dependências : tb_pag_espelhos, tb_pgto_periodo_rota, tb_pgto_periodo,
                 tb_fin_prefatura_descontos, tb_lista, tb_clientes, tb_bases,
                 tb_motorista, vw_Rotas
  ==============================================================================*/

SET NOCOUNT ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[UspFinGeraDescontoPagamento]
(
	@CodPeriodoPagamento int
) as 

declare @CodigoCliente int
declare @data_inicial DATE 
declare @data_final DATE
declare @IdTransportadora int
declare @IdCliTransportadora int
declare @operacao int

set @CodigoCliente = (select pgp_cd_cliente from tb_pgto_periodo where pgp_cd_periodo = @CodPeriodoPagamento)
set @data_inicial = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
set @data_final = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)
set @IdTransportadora = (select cli_id_logistics from tb_clientes where cli_cd_codigo_cliente=@CodigoCliente)
set @IdCliTransportadora = (

						select lst_cd_lista from tb_lista
						where lst_nm_lista = 'Clientes transportadoras'
						and lst_ds_label = 'Mercado Livre'
						and lst_cd_cliente in (
												select pgp_cd_cliente
												from [tb_pgto_periodo] as a
												left join tb_clientes as b
												on a.pgp_cd_cliente = cli_cd_codigo_cliente
												where pgp_cd_periodo  = @CodPeriodoPagamento
												)
												)

set @operacao = (
					select 
						lst_cd_lista 
					from 
						tb_lista with(nolock)
					where 
						lst_nm_lista = 'Operações Marketplace' 
						and lst_ds_valor = 'LM' 
						and lst_cd_cliente = @CodigoCliente
					)

declare @DataPrevistaPagamento date = (  
      
						select pgp_dt_prevista_pagamento  
						from [tb_pgto_periodo] as a (NOLOCK)  
						where pgp_cd_periodo  = @CodPeriodoPagamento
     
						)

--=============================================================================================================
-- ROTINA EXECUTA ATUALMENTE APENAS PARA PRALOG E APENAS PARA MELI, VALIDAR QUANDO DEMAIS CLIENTES ENTRAREM
-- CRIAR PARÂMETRO DE CLIENTE E DEIXÁ-LA DINÂMICA
-- AINDA PARA A PRALOG, ESTÁ COM UMA ERRO POIS ESTÃO ENTRANDO ROTAS COM VALORES MULOS NO ESPELHO EX ABAIXO:
-- select ppr_vl_total,* from tb_pgto_periodo_rota where  ppr_cd_periodo = 274 and ppr_cd_pgto_espelho = 270657
--=============================================================================================================


--Atualiza o UsuarioDA das rotas que estiverem no desconto
/*
update 
	r
set 
	r.UsuarioDA = usr_cd_usuario
from 
	tb_ml_rotas as r with(nolock)
	join tb_clientes as cli with(nolock) on cli.cli_id_logistics = r.IdTransportadora and cli.cli_cd_codigo_cliente = @CodigoCliente
	join tb_usuario as codusuario with(nolock) on r.NomeMotorista = codusuario.usr_nm_usuario and cli.cli_cd_codigo_cliente = codusuario.cli_cd_codigo_cliente
	join [dbo].[tb_fin_prefatura_descontos] d with(nolock) on r.IdRota = d.IdRota 
															and r.IdTransportadora = d.IdTransportadora 
															and cast(cast(d.Ano as varchar(4)) + '-' + cast(d.Mes as varchar(2)) + '-' + case when d.Quinzena = 1 then '01' else '16' end as date) between @data_inicial and @data_final  
where 
	excluido = 0
	and usr_in_ativo = 1
	and StatusRota <> 'planned'
*/



if @CodigoCliente = 49 

	begin
	--declare @CodPeriodoPagamento int = 245
	

	drop table if exists #desconto 
	select 
		@CodPeriodoPagamento as ppr_cd_periodo
		,a.DataReferencia as ppr_data_referencia
		,case when a.Descricao like '%Vehicle Daily Not Visited%' then cast(a.Idrota as varchar(50)) else cast(a.idpacote as varchar(50)) end as ppr_cd_rota
		,b.NomeMotorista as ppr_nome_motorista
		,b.UsuarioDA ppr_cd_motorista
		,case when left(OrigemSaida,1) = 'E' then OrigemSaida else ServiceCenter end ppr_base_principal
		,'Rota: ' + cast(a.IdRota as varchar) + ' Pacote: '+ cast(idpacote as varchar) + ' - ' + Descricao as ppr_lcto_observacao
		,(isnull(total,0) +(isnull(total,0)*0.2 )) *-1 as ppr_vl_total
		,(isnull(total,0) +(isnull(total,0)*0.2 )) * -1 as ppr_vl_desconto
	
		into #desconto
	from [dbo].[tb_fin_prefatura_descontos] as a
		inner join vw_Rotas as b
		on a.IdRota = b.idrota
		inner join tb_clientes as cli on b.IdTransportadora = cli.cli_id_logistics
		and cli.cli_cd_codigo_cliente = @CodigoCliente
	where 1=1 
	--and a.datareferencia between @data_inicial and @data_final
	and cast(cast(a.Ano as varchar(4)) + '-' + cast(a.Mes as varchar(2)) + '-' + case when a.Quinzena = 1 then '01' else '16' end as date) between @data_inicial and @data_final  
	--and Descricao = 'Lost Packages Penalty'
	--and b.NomeMotorista =  'Alexandre Augusto da Silva'
	--and a.idrota  = 190380352


	--INSERE PRIMEIRO O ESPELHO DAS ROTAS QUE NÃO GERARAM ESPELHO
	insert into tb_pag_espelhos (mtn_cd_motorista, mtn_nome_motorista, mtn_cd_pgto_periodo, mtn_cd_status, mtn_vl_nfs, mtn_ds_link_nfs, mtn_dt_prazo_contestacao, mtn_dh_criacao, mtn_cd_usr_criacao, mtn_dh_modificacao, mtn_cd_usr_modificacao, mtn_in_excluido, mtn_cod_cliente, mtn_qt_rotas, mtn_cd_tipo_espelho, mtn_cd_cliente_transportadora, mtn_cd_base, mtn_base_principal, mtn_cd_operacao, mtn_dt_prevista_pagamento)
	select 
		ppr_cd_motorista mtn_cd_motorista
		,ppr_nome_motorista as mtn_nome_motorista
		,ppr_cd_periodo as mtn_cd_pgto_periodo
		,228 mtn_cd_status
		,SUM(isnull(ppr_vl_total,0)) as mtn_vl_nfs
		,null mtn_ds_link_nfs
		,dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao
		,getdate() mtn_dh_criacao
		,8851 as mtn_cd_usr_criacao
		,getdate() mtn_dh_modificacao
		,8851 as mtn_cd_usr_modificacao
		,0 as mtn_in_excluido
		,@CodigoCliente as mtn_cod_cliente
		,count(*) as mtn_qt_rotas
		,94  as mtn_cd_tipo_espelho
		,@IdCliTransportadora as mtn_cd_cliente_transportadora
		,bss_cd_base as mtn_cd_base
		,ppr_base_principal mtn_base_principal
		,@operacao mtn_cd_operacao
		,@DataPrevistaPagamento mtn_dt_prevista_pagamento
	from 
		#desconto as a 
		left join tb_pag_espelhos as b on mtn_cd_motorista = ppr_cd_motorista and ppr_cd_periodo = mtn_cd_pgto_periodo and mtn_cd_operacao = @Operacao
		left join tb_bases as c on a.ppr_base_principal = c.bss_ds_sigla and c.bss_cd_idtransportadora = @IdTransportadora
	where
		b.mtn_cd_motorista_nfs is null
		and ppr_cd_motorista is not null
	group by
		ppr_cd_motorista
		,ppr_nome_motorista
		,ppr_cd_periodo
		,bss_cd_base
		,ppr_base_principal



	--update a
	--set
	-- a.ppr_vl_total		   = B.ppr_vl_total + b.ppr_vl_desconto
	--,a.ppr_vl_desconto	   = b.ppr_vl_desconto
	--,a.ppr_lcto_observacao = b.ppr_lcto_observacao

	--from tb_pgto_periodo_rota as a
	--inner join #desconto as b
	--on a.ppr_cd_rota = b.ppr_cd_rota

	--where a.ppr_cd_periodo = @CodPeriodoPagamento 

	

	insert into tb_pgto_periodo_rota (
		 ppr_data_referencia
		,ppr_cd_periodo
		,ppr_cd_rota
		,ppr_nome_motorista
		,ppr_cd_motorista
		,ppr_base_principal
		,ppr_lcto_observacao
		,ppr_vl_total
		,ppr_vl_desconto
		,ppr_dh_criacao
		,ppr_cd_usr_criacao
		,ppr_dh_modificacao
		,ppr_cd_usr_modificacao
		,ppr_in_ativo
		,ppr_in_excluido
		,ppr_cd_motorista_nfs
		,ppr_cd_pgto_espelho
		)
	select 
		 ppr_data_referencia
		,@CodPeriodoPagamento ppr_cd_periodo
		,ppr_cd_rota
		,ppr_nome_motorista
		,ppr_cd_motorista
		,ppr_base_principal
		,ppr_lcto_observacao
		,ppr_vl_total
		,ppr_vl_desconto
		,getdate() as ppr_dh_criacao
		,8851 as ppr_cd_usr_criacao
		,getdate() ppr_dh_modificacao
		,8851 as ppr_cd_usr_modificacao
		,1 as ppr_in_ativo
		,0 as ppr_in_excluido
		,mtn_cd_motorista_nfs as ppr_cd_motorista_nfs 
		,mtn_cd_motorista_nfs as ppr_cd_pgto_espelho

	from #desconto as a 
	left join tb_pag_espelhos as b
	on mtn_cd_motorista = ppr_cd_motorista
	and ppr_cd_periodo = mtn_cd_pgto_periodo
	and mtn_cd_operacao = @Operacao
	where 1=1 
	and ppr_cd_rota not in (
	select ppr_cd_rota from  tb_pgto_periodo_rota as a
	where ppr_cd_periodo = @CodPeriodoPagamento and ppr_cd_rota is not null)
	--AND PPR_CD_ROTA = '44142131756'


	update 
		a
	set 
		mtn_vl_nfs = isnull(total,0)
	from 
		tb_pag_espelhos a 
		inner join (
				select 
					sum(ppr_vl_total) as total
					,ppr_cd_pgto_espelho
				from 
					tb_pgto_periodo_rota as a
				where  
					ppr_cd_periodo = @CodPeriodoPagamento
					AND ppr_in_excluido = 0
					and ppr_fl_desconto = 0
				group by 
					ppr_cd_pgto_espelho
		) as b
		on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho 

end



--if @CodigoCliente in (11,47,37) 
if @CodigoCliente in (11,47) 

	begin
	--declare @CodPeriodoPagamento int = 245
	
															
	drop table if exists #desconto_50mais 
	select 
		@CodPeriodoPagamento as ppr_cd_periodo
		,a.DataReferencia as ppr_data_referencia
		,case when a.Descricao like '%Vehicle Daily Not Visited%' then cast(a.Idrota as varchar(50)) else cast(a.idpacote as varchar(50)) end as ppr_cd_rota
		,b.NomeMotorista as ppr_nome_motorista
		,b.UsuarioDA ppr_cd_motorista
		,case when left(OrigemSaida,1) = 'E' then OrigemSaida else ServiceCenter end as ppr_base_principal
		,'Rota: ' + cast(a.IdRota as varchar) + ' Pacote: '+ cast(idpacote as varchar) + ' - ' + Descricao as ppr_lcto_observacao
		,isnull(total,0) *-1 as ppr_vl_total
		,isnull(total,0) * -1 as ppr_vl_desconto
		into #desconto_50mais
	from 
		[dbo].[tb_fin_prefatura_descontos] as a
		inner join vw_Rotas as b
		on a.IdRota = b.idrota
		inner join tb_clientes as cli on b.IdTransportadora = cli.cli_id_logistics
		and cli.cli_cd_codigo_cliente = @CodigoCliente
	where 1=1 
	--and a.datareferencia between @data_inicial and @data_final
	and cast(cast(a.Ano as varchar(4)) + '-' + cast(a.Mes as varchar(2)) + '-' + case when a.Quinzena = 1 then '01' else '16' end as date) between @data_inicial and @data_final  
	and (
		(@CodigoCliente = 11 and a.Descricao not like '%Vehicle Daily Not Visited%') --os descontos de not vistied da 50+ são calculados através da procedure UspFinGeraDescontoNotVisited
		or
		@CodigoCliente <> 11
	)
    -- and a.idpacote  =  '44542560000' 


	/*
	--Tratativa para não gerar erro de pacotes duplicados 
	delete  #desconto_50mais
	where	ppr_cd_rota in  (47308976704
							,47299482955
							,47285112998
							,47270769741
							,47269466145
							,47239200007
							)
	*/


	
--INSERE PRIMEIRO O ESPELHO DAS ROTAS QUE NÃO GERARAM ESPELHO
	insert into tb_pag_espelhos (mtn_cd_motorista, mtn_nome_motorista, mtn_cd_pgto_periodo, mtn_cd_status, mtn_vl_nfs, mtn_ds_link_nfs, mtn_dt_prazo_contestacao, mtn_dh_criacao, mtn_cd_usr_criacao, mtn_dh_modificacao, mtn_cd_usr_modificacao, mtn_in_excluido, mtn_cod_cliente, mtn_qt_rotas, mtn_cd_tipo_espelho, mtn_cd_cliente_transportadora, mtn_cd_base, mtn_base_principal, mtn_cd_operacao, mtn_dt_prevista_pagamento)
	select 
		ppr_cd_motorista mtn_cd_motorista
		,ppr_nome_motorista as mtn_nome_motorista
		,ppr_cd_periodo as mtn_cd_pgto_periodo
		,228 mtn_cd_status
		,SUM(isnull(ppr_vl_total,0)) as mtn_vl_nfs
		,null mtn_ds_link_nfs
		,dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao
		,getdate() mtn_dh_criacao
		,8851 as mtn_cd_usr_criacao
		,getdate() mtn_dh_modificacao
		,8851 as mtn_cd_usr_modificacao
		,0 as mtn_in_excluido
		,@CodigoCliente as mtn_cod_cliente
		,count(*) as mtn_qt_rotas
		,94  as mtn_cd_tipo_espelho
		,@IdCliTransportadora as mtn_cd_cliente_transportadora
		,bss_cd_base as mtn_cd_base
		,ppr_base_principal mtn_base_principal
		,@operacao mtn_cd_operacao
		,@DataPrevistaPagamento mtn_dt_prevista_pagamento
	from 
		#desconto_50mais as a 
		left join tb_pag_espelhos as b on mtn_cd_motorista = ppr_cd_motorista and ppr_cd_periodo = mtn_cd_pgto_periodo and ppr_base_principal = mtn_base_principal and mtn_cd_operacao = @Operacao
		left join tb_bases as c on a.ppr_base_principal = c.bss_ds_sigla and c.bss_cd_idtransportadora = @IdTransportadora
	where
		b.mtn_cd_motorista_nfs is null
		and ppr_cd_motorista is not null
	group by
		ppr_cd_motorista
		,ppr_nome_motorista
		,ppr_cd_periodo
		,bss_cd_base
		,ppr_base_principal

-- JUSTIFICATIVA MERGE: sincroniza rotas de desconto sem duplicar; chave de
-- negocio (ppr_cd_rota, ppr_cd_periodo, ppr_cd_motorista) garantida por DISTINCT na source
merge into tb_pgto_periodo_rota as target
using (select distinct 
         ppr_data_referencia
        ,@CodPeriodoPagamento ppr_cd_periodo
        ,ppr_cd_rota
        ,ppr_nome_motorista
        ,ppr_cd_motorista
        ,ppr_base_principal
        ,ppr_lcto_observacao
        ,ppr_vl_total
        ,ppr_vl_desconto
        ,getdate() as ppr_dh_criacao
        ,8851 as ppr_cd_usr_criacao
        ,getdate() ppr_dh_modificacao
        ,8851 as ppr_cd_usr_modificacao
        ,1 as ppr_in_ativo
        ,0 as ppr_in_excluido
        ,mtn_cd_motorista_nfs as ppr_cd_motorista_nfs
        ,mtn_cd_motorista_nfs as ppr_cd_pgto_espelho
from #desconto_50mais as a
left join tb_pag_espelhos as b
--join tb_pag_espelhos as b
on mtn_cd_motorista = ppr_cd_motorista
and ppr_cd_periodo = mtn_cd_pgto_periodo
and mtn_cd_operacao = @Operacao
--Regra criada por Saulo Barros em 24/02/2025 para considerar para 50+ a chave Periodo, Motorista e SVC
and (
        (@CodigoCliente = 11 and a.ppr_base_principal = b.mtn_base_principal)
        or
        @CodigoCliente <> 11
    )
where 1=1

) as source
on target.ppr_cd_rota = source.ppr_cd_rota
and target.ppr_cd_periodo = source.ppr_cd_periodo
and target.ppr_cd_motorista = source.ppr_cd_motorista
and target.ppr_in_excluido = 0

when matched then update set 
        target.ppr_data_referencia = source.ppr_data_referencia,
        target.ppr_cd_rota = source.ppr_cd_rota,
        target.ppr_nome_motorista = source.ppr_nome_motorista,
        --target.ppr_cd_motorista = source.ppr_cd_motorista,
        target.ppr_base_principal = source.ppr_base_principal,
        target.ppr_lcto_observacao = source.ppr_lcto_observacao,
        target.ppr_vl_total = source.ppr_vl_total,
        target.ppr_vl_desconto = source.ppr_vl_desconto,
        target.ppr_dh_criacao = source.ppr_dh_criacao,
        target.ppr_cd_usr_criacao = source.ppr_cd_usr_criacao,
        target.ppr_dh_modificacao = source.ppr_dh_modificacao,
        target.ppr_cd_usr_modificacao = source.ppr_cd_usr_modificacao,
        target.ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs,
        target.ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho

when not matched then
   -- faca o inser na tabela tb_pgto_periodo_rota conforme o exemplo comentado acima
    insert (ppr_data_referencia, ppr_cd_periodo, ppr_cd_rota, ppr_nome_motorista, ppr_cd_motorista, ppr_base_principal, ppr_lcto_observacao, ppr_vl_total, ppr_vl_desconto, ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido, ppr_cd_motorista_nfs, ppr_cd_pgto_espelho)
    values (source.ppr_data_referencia, source.ppr_cd_periodo, source.ppr_cd_rota, source.ppr_nome_motorista, source.ppr_cd_motorista, source.ppr_base_principal, source.ppr_lcto_observacao, source.ppr_vl_total, source.ppr_vl_desconto, source.ppr_dh_criacao, source.ppr_cd_usr_criacao, source.ppr_dh_modificacao, source.ppr_cd_usr_modificacao, source.ppr_in_ativo, source.ppr_in_excluido, source.ppr_cd_motorista_nfs, source.ppr_cd_pgto_espelho);



	update 
		a
	set 
		mtn_vl_nfs = isnull(total,0)
	from 
		tb_pag_espelhos a 
		inner join (
				select 
					sum(ppr_vl_total) as total
					,ppr_cd_pgto_espelho
				from 
					tb_pgto_periodo_rota as a
				where  
					ppr_cd_periodo = @CodPeriodoPagamento
					AND ppr_in_excluido = 0
					and ppr_fl_desconto = 0
				group by 
					ppr_cd_pgto_espelho
				) as b
				on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho 

end

-- Atualizar Imposto e Valor Líquido
UPDATE ESP -- filtro WHERE no fim do bloco: ESP.mtn_cd_pgto_periodo = @CodPeriodoPagamento
SET mtn_vl_imposto = (CONVERT(DECIMAL(10,2),
						CASE
							WHEN MOT.mot_pag_cd_tipo_pagamento = 1
								THEN NULL
							WHEN MOT.mot_pag_cd_tipo_pagamento = 2
								THEN (ESP.mtn_vl_nfs * 0.06) * (0.135)
							ELSE NULL
						END)),
	mtn_vl_liquido = (CONVERT(DECIMAL(10,2),ESP.mtn_vl_nfs -
						(CASE
							WHEN MOT.mot_pag_cd_tipo_pagamento = 1
								THEN NULL
							WHEN MOT.mot_pag_cd_tipo_pagamento = 2
								THEN (ESP.mtn_vl_nfs * 0.06) * (0.135)
							ELSE NULL
						END)))
FROM tb_pag_espelhos AS ESP (NOLOCK)
INNER JOIN (
				SELECT	*,
						ROW_NUMBER() OVER(PARTITION BY mot_cd_usuario ORDER BY mot_cd_motorista ASC)	AS ID
				FROM tb_motorista (NOLOCK)
			) AS MOT ON MOT.mot_cd_usuario = ESP.mtn_cd_motorista
								AND MOT.ID = 1
WHERE ESP.mtn_cd_pgto_periodo = @CodPeriodoPagamento




if @CodigoCliente in (33) 
-- desconto de taxa de insucessos da Avista

	begin

		update tb_pgto_periodo_rota -- filtro WHERE no fim do bloco: ppr_cd_periodo = @CodPeriodoPagamento and ppr_vl_success_delivery < 0.90 and ppr_vl_base > 0
		set 
			ppr_lcto_observacao = 'Baixo percentual de entrega',
			ppr_vl_base = case 
							when ppr_vl_success_delivery < 0.90 then (ppr_vl_success_delivery * ppr_vl_base) 
							when ppr_in_dom_fer = 1 and ppr_vl_success_delivery < 0.70  then (ppr_vl_success_delivery * ppr_vl_base) else ppr_vl_base end 

			,ppr_vl_total = ppr_vl_dom_fer + ppr_vl_bonus + ppr_vl_ajudante + ppr_vl_paradas +
							case 
								when ppr_vl_success_delivery < 0.90 then (ppr_vl_success_delivery * ppr_vl_base) 
								when ppr_in_dom_fer = 1 and ppr_vl_success_delivery < 0.70  then (ppr_vl_success_delivery * ppr_vl_base) else ppr_vl_base end
	
		from tb_pgto_periodo_rota
		where ppr_cd_periodo = @CodPeriodoPagamento
		and ppr_vl_success_delivery < 0.90
		and ppr_vl_base > 0


	end
--select * from tb_clientes

--SELECT * FROM tb_pgto_periodo_rota 
--WHERE 1=1
--and ppr_cd_periodo = 245 
--AND ppr_nome_motorista = 'Flavio Brasil Maciel'

--AND PPR_CD_ROTA = '44142131756'

--select * from #desconto where ppr_base_principal = 'SRJ6'
--245

--mtn_cd_base	mtn_base_principal
--NULL	NULL
GO

BEGIN TRY
    IF OBJECT_ID(N'dbo.UspFinGeraDescontoPagamento') IS NULL
        THROW 51000, 'Falha: procedure nao encontrada apos deploy.', 1;
    PRINT 'SUCESSO: UspFinGeraDescontoPagamento atualizada.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
