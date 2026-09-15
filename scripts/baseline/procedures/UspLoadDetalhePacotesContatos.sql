-- ============================================================
-- BASELINE: dbo.UspLoadDetalhePacotesContatos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspLoadDetalhePacotesContatos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspLoadDetalhePacotesContatos]
AS
BEGIN

/*

truncate table tb_ml_detalhes_pacotes
truncate table tb_ml_checkpoints

declare @json varchar(max),
        @IdPacote bigint,
        @IdTransportadora int
select @json = dac_ds_contexto_json,
         @IdPacote = dac_ds_contexto,
         @IdTransportadora = dac_cd_transportadora
from db_Irisys_Json.dbo.tb_dra_coleta
where dac_cd_coleta = 4774109

exec UspLoadDetalhePacotes @json, @idPacote, @IdTransportadora


select * from tb_ml_detalhes_pacotes
select * from tb_ml_checkpoints

*/


-- declare @json varchar(max),
--         @IdPacote bigint,
--         @IdTransportadora int


drop table if exists #aux
select top 1000 
	dac_cd_coleta
	,dac_ds_contexto_json 
	,dac_cd_transportadora idtransportadora
	,dac_dh_coleta
	,dac_ds_contexto
	-- =,ROW_NUMBER() over (partition by dac_ds_contexto order by dac_dh_coleta desc) as rownum	
into #aux

from db_Irisys_Json.dbo.tb_dra_coleta
where  dac_ds_tipo_coleta = 'ML_PACKAGE_CASE_DETAIL'
and dac_in_processado = 0


DROP TABLE IF EXISTS #detalhes;
SELECT TOP (10000000) *,
       jroot.route_id        AS idrota,
       jship.shipmentId      AS IdPacote
INTO #detalhes
FROM #aux AS aux
CROSS APPLY OPENJSON(aux.dac_ds_contexto_json)
WITH (
    route_id     INT          '$.routeData.routeId',
    Contato1     VARCHAR(150) '$.contactData.contacts[0].name',
    telefone1    VARCHAR(150) '$.contactData.contacts[0].phone',
    email1       VARCHAR(150) '$.contactData.contacts[0].email',
    Contato2     VARCHAR(150) '$.contactData.contacts[1].name',
    telefone2    VARCHAR(150) '$.contactData.contacts[1].phone',
    email2       VARCHAR(150) '$.contactData.contacts[1].email',
    Contato3     VARCHAR(150) '$.contactData.contacts[2].name',
    telefone3    VARCHAR(150) '$.contactData.contacts[2].phone',
    email3       VARCHAR(150) '$.contactData.contacts[2].email'
) AS jroot
CROSS APPLY OPENJSON(aux.dac_ds_contexto_json, '$.shipmentsData.shipments')
WITH (
    shipmentId  BIGINT '$.shipmentId'
) AS jship
WHERE jship.shipmentId = aux.dac_ds_contexto;


delete from #detalhes
where dac_cd_coleta in (
	
select dac_cd_coleta
from (
select
ROW_NUMBER() over (partition by IdPacote order by dac_dh_coleta desc) ordem
, *
 from #detalhes
) as a
where ordem > 1

)


merge tb_ml_detalhes_pacotes as target
using #detalhes as source
on target.IdPacote = source.IdPacote
and target.idtransportadora = source.idtransportadora

when matched then
	update set
		target.NomeContato1 = source.Contato1,
		target.TelefoneContato1 = isnull(source.telefone1,'N/D'),
		target.EmailContato1 = source.email1,
		target.NomeContato2 = source.Contato2,
		target.TelefoneContato2 = source.telefone2,
		target.EmailContato2 = source.email2,
		target.NomeContato3 = source.Contato3,
		target.TelefoneContato3 = source.telefone3,
		target.EmailContato3 = source.email3;

   
update db_Irisys_Json.dbo.tb_dra_coleta
set dac_in_processado = 1
where dac_cd_coleta in (select dac_cd_coleta from #aux)


--select count(*) from tb_ml_detalhes_pacotes
--where NomeContato1 is not null

END
GO
