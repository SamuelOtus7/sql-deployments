-- ============================================================
-- BASELINE: dbo.UspAtualizaMotoristasLogistics
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaMotoristasLogistics]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspAtualizaMotoristasLogistics]
as

begin

--procedure não utilizada!!!!


drop table if exists #motoristas

select base.dac_cd_transportadora as IdTransportadora
	   ,base.dac_ds_contexto as IdMotorista
	   ,base.dac_dh_coleta as DataHoraColeta
	   ,case when identificationType = 'CPF' then identificationValue else null end CPF
	   ,case when identificationType = 'CNPJ' then identificationValue else null end CNPJ
	   ,id							as Id
	   ,identificationValue			as Documento
	   ,case when firstName = lastname then firstname else firstname + ' ' + lastName end as Nome
	   ,case when disabled = 'false' then 1 else 0 end Ativo
	   ,firstName					as PrimeiroNome
	   ,lastName					as UltimoNome
	   ,email						as Email
	   ,phone						as Telefone
	   ,DATEADD(SECOND, creationDate, '1970-01-01 00:00:00:000') as DataHoraCriacao
	   ,DATEADD(SECOND, lastUpdated, '1970-01-01 00:00:00:000') as DataHoraUltimaAtualizacao
	   ,status						as Status
	   ,carrierId					as CarrierId
	   ,siteId						as Site
	   ,blockingReason				as MotivoBloqueio
	   ,infractionStatus			as StatusInfracao
	   ,insurer						as Seguradora
	   ,isCrowdDriver				as MotoristaExterno
	   ,tasks						as Atividades
	   ,hasChangeStatusInProgress   as AlterandoStatus
into #motoristas
from (
		select a.dac_ds_contexto,
			   a.dac_ds_contexto_json,
			   a.dac_cd_transportadora,
			   a.dac_dh_coleta
		from db_Irisys_Json.dbo.tb_dra_coleta a
			join (
					select dac_ds_contexto,
						   dac_cd_transportadora,
						   max(dac_dh_escrita) as ultimo
					from db_Irisys_Json.dbo.tb_dra_coleta
					where dac_ds_tipo_coleta = 'DRIVER_ML'
						  and dac_dh_escrita >= dateadd(day,-1,cast(getdate() as date))
					group by dac_ds_contexto,
						     dac_cd_transportadora
				 ) b
			on a.dac_ds_contexto = b.dac_ds_contexto
			and a.dac_cd_transportadora = b.dac_cd_transportadora
			and a.dac_dh_escrita = b.ultimo
		where dac_ds_tipo_coleta = 'DRIVER_ML'
		and dac_dh_escrita >= dateadd(day,-1,cast(getdate() as date))
	 ) as base
	 cross apply (
		select *
		from openjson (dac_ds_contexto_json)
		with (
				identificationType		  varchar(250) '$.identificationType',
				id						  varchar(250) '$.id',			 
				identificationValue		  varchar(250) '$.identificationValue',		 
				firstName				  varchar(250) '$.firstName',				 
				lastName				  varchar(250) '$.lastName',				 
				disabled				  varchar(250) '$.disabled',				 
				email					  varchar(250) '$.email',					 
				phone					  varchar(250) '$.phone',					 
				creationDate			  bigint       '$.creationDate',			 
				lastUpdated				  bigint       '$.lastUpdated',				 
				status					  varchar(250) '$.status',					 
				carrierId				  varchar(250) '$.carrierId',				 
				siteId					  varchar(250) '$.siteId',					 
				blockingReason			  varchar(250) '$.blockingReason',			 
				infractionStatus		  varchar(250) '$.infractionStatus',		 
				insurer					  varchar(250) '$.insurer',					 
				isCrowdDriver			  varchar(250) '$.isCrowdDriver',			 
				tasks					  varchar(250) '$.tasks',					 
				hasChangeStatusInProgress varchar(250) '$.hasChangeStatusInProgress'
			 )
	 ) as json
/*
MERGE tb_ml_motoristas_logistics as target
	USING #motoristas as source 
	on target.IdMotorista = source.IdMotorista
	and target.IdTransportadora = source.IdTransportadora
	WHEN MATCHED AND
			(
				   target.TipoDocumento				<> source.TipoDocumento
				or target.Id							<> source.Id
				or target.Documento					<> source.Documento
				or target.PrimeiroNome					<> source.PrimeiroNome
				or target.UltimoNome					<> source.UltimoNome
				or target.Email						<> source.Email
				or target.Telefone						<> source.Telefone
				or target.DataHoraCriacao				<> source.DataHoraCriacao
				or target.DataHoraUltimaAtualizacao	<> source.DataHoraUltimaAtualizacao
				or target.Status						<> source.Status
				or target.CarrierId					<> source.CarrierId
				or target.Site							<> source.Site
				or target.MotivoBloqueio				<> source.MotivoBloqueio
				or target.StatusInfracao				<> source.StatusInfracao
				or target.Seguradora					<> source.Seguradora
				or target.MotoristaExterno				<> source.MotoristaExterno
				or target.Atividades					<> source.Atividades
				or target.AlterandoStatus				<> source.AlterandoStatus
			)	
	THEN UPDATE SET
				target.IdTransportadora				= source.IdTransportadora
				,target.IdMotorista					= source.IdMotorista
				,target.TipoDocumento				= source.TipoDocumento
				,target.Id							= source.Id
				,target.Documento					= source.Documento
				,target.PrimeiroNome				= source.PrimeiroNome
				,target.UltimoNome					= source.UltimoNome
				,target.Email						= source.Email
				,target.Telefone					= source.Telefone
				,target.DataHoraCriacao				= source.DataHoraCriacao
				,target.DataHoraUltimaAtualizacao	= source.DataHoraUltimaAtualizacao
				,target.Status						= source.Status
				,target.CarrierId					= source.CarrierId
				,target.Site						= source.Site
				,target.MotivoBloqueio				= source.MotivoBloqueio
				,target.StatusInfracao				= source.StatusInfracao
				,target.Seguradora					= source.Seguradora
				,target.MotoristaExterno			= source.MotoristaExterno
				,target.Atividades					= source.Atividades
				,target.AlterandoStatus				= source.AlterandoStatus
	WHEN NOT MATCHED BY TARGET
	THEN INSERT  (
					 IdTransportadora
					,IdMotorista
					,TipoDocumento
					,Id
					,Documento
					,PrimeiroNome
					,UltimoNome
					,Email
					,Telefone
					,DataHoraCriacao
					,DataHoraUltimaAtualizacao
					,Status
					,CarrierId
					,Site
					,MotivoBloqueio
					,StatusInfracao
					,Seguradora
					,MotoristaExterno
					,Atividades
					,AlterandoStatus
				)
	VALUES (
				source.IdTransportadora
				,source.IdMotorista
				,source.TipoDocumento
				,source.Id
				,source.Documento
				,source.PrimeiroNome
				,source.UltimoNome
				,source.Email
				,source.Telefone
				,source.DataHoraCriacao
				,source.DataHoraUltimaAtualizacao
				,source.Status
				,source.CarrierId
				,source.Site
				,source.MotivoBloqueio
				,source.StatusInfracao
				,source.Seguradora
				,source.MotoristaExterno
				,source.Atividades
				,source.AlterandoStatus
		  );
*/


MERGE tb_ml_motoristas as target
	USING #motoristas as source 
	on target.IdMotorista = source.IdMotorista
	and target.IdTransportadora = source.IdTransportadora
	WHEN MATCHED AND
			(
			   target.CPF					<> source.Documento
			or target.CNPJ					<> source.Documento
			or target.Nome					<> left(source.Nome,60)
			or target.Ativo					<> source.Ativo
			or target.Email					<> source.Email
			or target.Telefone				<> source.Telefone
			or target.DataCriacao			<> source.DataHoraCriacao
			or target.UltimaAtualizacao		<> source.DataHoraUltimaAtualizacao
			or target.IdSite				<> source.Site
			or target.DataColeta			<> source.DataHoraColeta
			/*
				   target.TipoDocumento				<> source.TipoDocumento
				or target.Id							<> source.Id
				or target.Documento					<> source.Documento
				or target.PrimeiroNome					<> source.PrimeiroNome
				or target.UltimoNome					<> source.UltimoNome
				or target.Email						<> source.Email
				or target.Telefone						<> source.Telefone
				or target.DataHoraCriacao				<> source.DataHoraCriacao
				or target.DataHoraUltimaAtualizacao	<> source.DataHoraUltimaAtualizacao
				or target.Status						<> source.Status
				or target.CarrierId					<> source.CarrierId
				or target.Site							<> source.Site
				or target.MotivoBloqueio				<> source.MotivoBloqueio
				or target.StatusInfracao				<> source.StatusInfracao
				or target.Seguradora					<> source.Seguradora
				or target.MotoristaExterno				<> source.MotoristaExterno
				or target.Atividades					<> source.Atividades
				or target.AlterandoStatus				<> source.AlterandoStatus*/
			)	
	THEN UPDATE SET
				 target.CPF					= source.CPF
				,target.CNPJ				= source.CNPJ
				,target.Nome				= left(source.Nome,60)
				,target.Ativo				= source.Ativo
				,target.Email				= source.Email
				,target.Telefone			= source.Telefone
				,target.DataCriacao			= source.DataHoraCriacao
				,target.UltimaAtualizacao	= source.DataHoraUltimaAtualizacao
				,target.IdSite				= source.Site
				,target.DataColeta			= source.DataHoraColeta			

	WHEN NOT MATCHED BY TARGET
	THEN INSERT  (
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
				)
	VALUES (
				 source.IdMotorista
				,source.IdTransportadora
				,source.CPF
				,source.CNPJ
				,left(source.Nome,60)
				,source.Ativo
				,source.Email
				,source.Telefone
				,source.DataHoraCriacao
				,source.DataHoraUltimaAtualizacao
				,source.Site
				,source.DataHoraColeta			
		  );

end
GO
