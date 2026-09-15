-- ============================================================
-- BASELINE: dbo.UspMLLoadMotoristas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLLoadMotoristas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspMLLoadMotoristas](
	@JSON VARCHAR(max),
	@DataColeta datetime
)as
begin
	
	SET NOCOUNT ON
	/*

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
	)

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
		,@DataColeta DataColeta
	from
		OPENJSON(@Json)
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
			,creationDate varchar(20) '$.creationDate'
			,lastUpdated varchar(20) '$.lastUpdated'
			,status varchar(20) '$.status'
			,carrierId int '$.carrierId'
			,siteId varchar(30) '$.siteId'
		)

		
		
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
	);


	insert into tb_ml_aprovacao_usuario (mau_ds_tipo_documento, mau_cd_logistics, mau_ds_documento, mau_nm_completo, mau_in_habilitado, mau_ds_email, mau_ds_telefone, mau_ds_status, mau_cd_usuario_aprovacao, mau_cd_cliente, mau_ds_site, mau_dh_aprovacao, mau_cd_usuario_gerado, mau_in_ativo, mau_in_excluido, mau_cd_usuario_criacao, mau_dh_criacao, mau_cd_usuario_modificacao, mau_dh_modificacao, mau_ds_origem)
	select
		case when CPF is not null then 'CPF' else case when CNPJ is not null then 'CNPJ' else 'Não Informado' end end tipo_documento,
		m.IdMotorista id,
		coalesce(CPF,CNPJ,'Não Informado') documento,
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
		'Silos' as mau_ds_origem
	from
		tb_ml_motoristas m
		join tb_clientes c on m.IdTransportadora = c.cli_id_logistics
		left join tb_ml_aprovacao_usuario apmail
		on m.Email = apmail.mau_ds_email and apmail.mau_cd_cliente = c.cli_cd_codigo_cliente
		left join tb_ml_aprovacao_usuario apnome
		on m.Email = apnome.mau_ds_email and apnome.mau_cd_cliente = c.cli_cd_codigo_cliente
		left join tb_usuario as users
		on m.Email = users.usr_ds_email and c.cli_cd_codigo_cliente = users.cli_cd_codigo_cliente
	where
		apmail.mau_cd_aprovacao is null
		and apnome.mau_cd_aprovacao is null
		and users.usr_cd_usuario is null
	
	*/

end
GO
