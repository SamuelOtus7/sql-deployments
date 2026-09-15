-- ============================================================
-- BASELINE: dbo.UspMLGetMotoristas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLGetMotoristas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspMLGetMotoristas]
as 
begin

	drop table if exists #motoristas
	CREATE TABLE #motoristas (
		[IdMotorista] [int] NOT NULL,
		[IdTransportadora] [int] NULL,
		[CPF] [varchar](14) NULL,
		[CNPJ] [varchar](14) NULL,
		[Nome] [varchar](60) NULL,
		[Ativo] [bit] NOT NULL,
		[Email] [varchar](60) NULL,
		[Telefone] [varchar](20) NULL,
		[DataCriacao] [datetime] NULL,
		[UltimaAtualizacao] [datetime] NULL,
		[IdSite] [varchar](30) NULL,
		[DataColeta] datetime not null,
		CodigoColeta bigint not null,
        Ajudante bit NULL
	)
	CREATE NONCLUSTERED INDEX idx_motoristas_data_coleta
ON #motoristas (DataColeta);


	insert into #motoristas
	select 
		id IdMotorista
		,carrierId IdTransportadora
		,case when identificationType = 'CPF' then identificationValue else null end CPF
		,case when identificationType = 'CNPJ' then identificationValue else null end CNPJ
		,firstName + ' ' + lastName Nome
		,case when [disabled] = 'false' then 1 else 0 end Ativo
		,email Email
		,phone Telefone
		,dateadd(second,((cast(creationDate as bigint))) - 10800,'1970-01-01') DataCriacao
		,dateadd(second,((cast(lastUpdated as bigint))) - 10800,'1970-01-01') UltimaAtualizacao
		,siteId IdSite
		,base.dac_dh_coleta DataColeta
		,base.dac_cd_coleta
		,json.isOnlyHelper as Ajudante

	FROM (
			select a.* 
			from db_Irisys_Json.dbo.tb_dra_coleta a
				join (
						select dac_cd_transportadora,
							   dac_ds_contexto, 
							   max(dac_cd_coleta) as dac_cd_coleta 
						from db_Irisys_Json.dbo.tb_dra_coleta
						where dac_dh_coleta >= cast(getdate()-10 as date)
						and dac_ds_tipo_coleta = 'DRIVER_ML' 
						and dac_in_processado = 0 
						group by dac_cd_transportadora,
							     dac_ds_contexto
					 ) as ultimo
				on a.dac_cd_coleta = ultimo.dac_cd_coleta
			where 1 =1 
			and dac_in_processado = 0 
			and dac_ds_tipo_coleta = 'DRIVER_ML' 
		 ) as base
	CROSS APPLY (
		SELECT *
		FROM OPENJSON(dac_ds_contexto_json)
		WITH
			(
				id int '$.id'
				,identificationType varchar(30) '$.identificationType'
				,identificationValue varchar(20) '$.identificationValue'
				,firstName varchar(60) '$.firstName'
				,lastName varchar(60) '$.lastName'
				,[disabled] varchar(20) '$.disabled'
				,email varchar(60) '$.email'
				,phone varchar(20) '$.phone'
				,creationDate BIGINT '$.creationDate'
				,lastUpdated BIGINT '$.lastUpdated'
				,status varchar(20) '$.status'
				,carrierId int '$.carrierId'
				,siteId varchar(30) '$.siteId'
                ,isOnlyHelper bit '$.isOnlyHelper'
			)
	) as json
	
		
	delete mot
	from #motoristas as mot
		left join (
				select Email, IdTransportadora, max(CodigoColeta) as CodigoColeta
				from #motoristas
				group by Email, IdTransportadora
			 ) as ultimoEmail
		on mot.CodigoColeta = ultimoEmail.CodigoColeta
		left join (
				select Nome, IdTransportadora, max(CodigoColeta) as CodigoColeta
				from #motoristas
				group by Nome, IdTransportadora
			 ) as ultimoNome
		on mot.CodigoColeta = ultimoNome.CodigoColeta
	where ultimoEmail.CodigoColeta is null or ultimoNome.CodigoColeta is null


	merge tb_ml_motoristas as m
	using #motoristas as i
		ON m.IdMotorista = i.IdMotorista and m.IdTransportadora = i.IdTransportadora
	when matched then
	update set
		m.CPF = i.CPF
		,m.CNPJ = i.CNPJ
		,m.Nome = i.Nome
		,m.Ativo = i.Ativo
		,m.Email = i.Email
		,m.Telefone = i.Telefone
		,m.DataCriacao = i.DataCriacao
		,m.UltimaAtualizacao = i.UltimaAtualizacao
		,m.IdSite = i.IdSite
		,m.DataColeta = i.DataColeta
        ,m.ajudante = i.Ajudante
	when not matched by target then 
	insert (
			IdMotorista
			,IdTransportadora
			,CPF
			,CNPJ
			,Nome
			,Ativo
			,Email
			,Telefone
			,DataCriacao
			,UltimaAtualizacao
			,IdSite
			,DataColeta
            ,Ajudante
	) values (
			i.IdMotorista
			,i.IdTransportadora
			,i.CPF
			,i.CNPJ
			,i.Nome
			,i.Ativo
			,i.Email
			,i.Telefone
			,i.DataCriacao
			,i.UltimaAtualizacao
			,i.IdSite
			,i.DataColeta
            ,i.ajudante
	);

	/*
	Verificar com samuel se podemos alterar para buscar os motoristas assim por conta de erro de chave uma vez que no meli ta vindo mais de um usuario com
	mesmo nome e mesmo cpf na transportadora
	select
		m.*
	from
		tb_ml_motoristas m with(nolock)
		join (
				select
					IdTransportadora
					,CPF
					,max(DataCriacao) DataCriacao
				from
					tb_ml_motoristas with(nolock)
				where
					Ativo = 1
				group by
					IdTransportadora
					,CPF
			) m2 on m.IdTransportadora = m2.IdTransportadora
				and m.CPF = m2.CPF
				and m.DataCriacao = m2.DataCriacao
	where
		m.Ativo = 1
	*/

	insert into tb_ml_aprovacao_usuario (mau_ds_tipo_documento, mau_cd_logistics, mau_ds_documento, mau_nm_completo, mau_in_habilitado
    , mau_ds_email, mau_ds_telefone, mau_ds_status, mau_cd_usuario_aprovacao, mau_cd_cliente, mau_ds_site, mau_dh_aprovacao
    , mau_cd_usuario_gerado, mau_in_ativo, mau_in_excluido, mau_cd_usuario_criacao, mau_dh_criacao, mau_cd_usuario_modificacao
    , mau_dh_modificacao, mau_ds_origem, mau_ds_ajudante)
	select
		case when m.CPF is not null then 'CPF' else case when m.CNPJ is not null then 'CNPJ' else 'Não Informado' end end tipo_documento,
		m.IdMotorista id,
		coalesce(m.CPF,m.CNPJ,'Não Informado') documento,
		m.Nome nome,
		m.Ativo habilitado,
		m.Email email,
		m.Telefone telefone,
		'Em análise' status,
		null usuario_aprovacao,
		c.cli_cd_codigo_cliente cliente,
		m.IdSite,
		null dhaprovacao,
		null usuario_gerado,
		1 ativo,
		0 excluido,
		4039 usuario_criacao,
		getdate() criacao,
		4039 usuario_modificacao,
		getdate() dh_modificacao,
		'Silos' as mau_ds_origem,
        isnull(m.ajudante, 0) as ajudante

	from
		tb_ml_motoristas m
		join (
				select
					IdTransportadora
					,CPF
					,max(IdMotorista) IdMotorista
				from
					tb_ml_motoristas
				group by
					IdTransportadora
					,CPF
			) m2 on m.IdTransportadora = m2.IdTransportadora and m.CPF = m2.CPF and m.IdMotorista = m2.IdMotorista
		join tb_clientes c on m.IdTransportadora = c.cli_id_logistics
		left join tb_ml_aprovacao_usuario apmail
		on case 
			when apmail.mau_ds_email like '%_expirado%' then left(apmail.mau_ds_email,charindex('_expirado',apmail.mau_ds_email,1) -1)
			when apmail.mau_ds_email like '%_inativo%' then left(apmail.mau_ds_email,charindex('_inativo',apmail.mau_ds_email,1) -1)
			when apmail.mau_ds_email like '%_reprovado%' then left(apmail.mau_ds_email,charindex('_reprovado',apmail.mau_ds_email,1) -1)
			when apmail.mau_ds_email like '%_deletado%' then left(apmail.mau_ds_email,charindex('_deletado',apmail.mau_ds_email,1) -1)
			else apmail.mau_ds_email
		end = m.Email and apmail.mau_cd_cliente = c.cli_cd_codigo_cliente
		left join tb_ml_aprovacao_usuario apnome
						on case 
							when apnome.mau_nm_completo like '%_expirado%' then left(apnome.mau_nm_completo,charindex('_expirado',apnome.mau_nm_completo,1) -1)
							when apnome.mau_nm_completo like '%_inativo%' then left(apnome.mau_nm_completo,charindex('_inativo',apnome.mau_nm_completo,1) -1)
							when apnome.mau_nm_completo like '%_reprovado%' then left(apnome.mau_nm_completo,charindex('_reprovado',apnome.mau_nm_completo,1) -1)
							when apnome.mau_nm_completo like '%_deletado%' then left(apnome.mau_nm_completo,charindex('_deletado',apnome.mau_nm_completo,1) -1)
							else apnome.mau_nm_completo
						end = m.Nome and apnome.mau_cd_cliente = c.cli_cd_codigo_cliente
							and apnome.mau_cd_cliente not in (select 
															prm_cod_cliente
														from
															tb_parametros with(nolock)
														where
															prm_cod_cliente is not null
															and prm_nm_parametro = 'Habilitar Homônimos Usuários'
															and prm_in_ativo = 1
															and prm_in_excluido = 0
															and prm_ds_valor = 'true'
														)
		
		--para os clientes que aceitam nome também é verificado documento
		left join tb_ml_aprovacao_usuario apnomedoc
							on case 
								when apnomedoc.mau_nm_completo like '%_expirado%' then left(apnomedoc.mau_nm_completo,charindex('_expirado',apnomedoc.mau_nm_completo,1) -1)
								when apnomedoc.mau_nm_completo like '%_inativo%' then left(apnomedoc.mau_nm_completo,charindex('_inativo',apnomedoc.mau_nm_completo,1) -1)
								when apnomedoc.mau_nm_completo like '%_reprovado%' then left(apnomedoc.mau_nm_completo,charindex('_reprovado',apnomedoc.mau_nm_completo,1) -1)
								when apnomedoc.mau_nm_completo like '%_deletado%' then left(apnomedoc.mau_nm_completo,charindex('_deletado',apnomedoc.mau_nm_completo,1) -1)
								else apnomedoc.mau_nm_completo
							end = m.Nome 
							and apnomedoc.mau_cd_cliente = c.cli_cd_codigo_cliente
							and apnomedoc.mau_ds_documento = coalesce(m.CPF,m.CNPJ,'Não Informado')
							and apnomedoc.mau_cd_cliente in (select 
															prm_cod_cliente
														from
															tb_parametros with(nolock)
														where
															prm_cod_cliente is not null
															and prm_nm_parametro = 'Habilitar Homônimos Usuários'
															and prm_in_ativo = 1
															and prm_in_excluido = 0
															and prm_ds_valor = 'true'
														)


		left join tb_usuario as users
		on m.Email = users.usr_ds_email and c.cli_cd_codigo_cliente = users.cli_cd_codigo_cliente
	where
		apmail.mau_cd_aprovacao is null
		and apnome.mau_cd_aprovacao is null
		and users.usr_cd_usuario is null
		and apnomedoc.mau_cd_aprovacao is null

	update b
	set b.dac_in_processado = 1
	from #motoristas as a
	inner join db_Irisys_Json.dbo.tb_dra_coleta as b
	on a.CodigoColeta = b.dac_cd_coleta


end
	
GO
