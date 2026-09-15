-- ============================================================
-- BASELINE: dbo.UspValidacaoNomenclatura
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspValidacaoNomenclatura]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspValidacaoNomenclatura]

as

drop table if exists #tipos
create table #tipos
(
	tipo varchar(30),
	padrao1 char(2),
	padrao2 char(2),
	padrao3 char(2)
)

insert into #tipos values ('image'					,'im','','')
insert into #tipos values ('text'					,'nm','ds','ob')
insert into #tipos values ('uniqueidentifier'		,'ui','','')
insert into #tipos values ('date'					,'dt','','')
insert into #tipos values ('time'					,'tm','','')
insert into #tipos values ('datetime2'				,'dh','','')
insert into #tipos values ('datetimeoffset'			,'dh','','')
insert into #tipos values ('tinyint'				,'cd','no','')
insert into #tipos values ('smallint'				,'cd','no','')
insert into #tipos values ('int'					,'cd','no','')
insert into #tipos values ('smalldatetime'			,'dh','vl','')
insert into #tipos values ('real'					,'dc','vl','')
insert into #tipos values ('money'					,'dc','vl','')
insert into #tipos values ('datetime'				,'dh','','')
insert into #tipos values ('float'					,'dc','vl','')
insert into #tipos values ('sql_variant'			,'vr','','')
insert into #tipos values ('ntext'					,'nm','ds','ob')
insert into #tipos values ('bit'					,'in','','')
insert into #tipos values ('decimal'				,'dc','vl','')
insert into #tipos values ('numeric'				,'dc','vl','')
insert into #tipos values ('smallmoney'				,'dc','vl','')
insert into #tipos values ('bigint'					,'cd','no','')
insert into #tipos values ('hierarchyid'			,'hi','','')
insert into #tipos values ('geometry'				,'gm','','')
insert into #tipos values ('geography'				,'gg','','')
insert into #tipos values ('varbinary'				,'bi','','')
insert into #tipos values ('varchar'				,'nm','ds','ob')
insert into #tipos values ('binary'					,'bi','','')
insert into #tipos values ('char'					,'nm','ds','ob')
insert into #tipos values ('timestamp'				,'ts','','')
insert into #tipos values ('nvarchar'				,'nm','ds','ob')
insert into #tipos values ('nchar'					,'nm','ds','ob')
insert into #tipos values ('xml'					,'xm','','')
insert into #tipos values ('sysname'				,'sn','','')



select 'Nomes de campos' as Validacao,
	   tables.name as objeto,
	   columns.name,
	   padroes.tipo,
	   padroes.padrao1,
	   padroes.padrao2,
	   padroes.padrao3,
	   substring(columns.name,5,2) as Atual,
	   'exec sp_rename ''' + tables.name + '.' + columns.name + ''',''' + left(columns.name,4) + padrao1 + right(columns.name,len(columns.name) - 6) + '''' as SugestaoScript
from sys.columns
	inner join sys.types on columns.system_type_id = types.system_type_id
	inner join #tipos as padroes on types.name = padroes.tipo
	inner join sys.tables on columns.object_id = tables.object_id
where (
		substring(columns.name,5,2) <> padroes.padrao1 and
		substring(columns.name,5,2) <> padroes.padrao2 and
		substring(columns.name,5,2) <> padroes.padrao3 
	  )

union all

select 'Nulidade dos campos' as Validacao,
	   tables.name as objeto,
	   columns.name,
	   types.name,
	   'Não nulo' as padrao1,
	   '' as padrao2,
	   '' as padrao3,
	   'Nulo' as Atual,
	   'alter table ' + tables.name + ' alter column ' + columns.name + ' ' + columns.name + case when columns.name = 'varchar' then '(' + cast(columns.max_length as varchar(10)) + ')' else '' end + ' not null'
from sys.columns
	join sys.tables on columns.object_id = tables.object_id
	join sys.types on columns.system_type_id = types.system_type_id
where columns.is_nullable = 1
--	  and b.name <> 'tb_logs'
	  and left(columns.name,3) <> 'pai'
	  and (tables.name = 'tb_pf_usuarios' or columns.name not in ('usr_cd_usr_criacao','usr_cd_usr_modificacao'))
GO
