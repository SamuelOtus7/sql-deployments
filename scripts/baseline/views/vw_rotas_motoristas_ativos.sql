-- ============================================================
-- BASELINE: dbo.vw_rotas_motoristas_ativos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_motoristas_ativos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_rotas_motoristas_ativos]  
as  

WITH MotoristaUltimaRota AS (
   SELECT
       e.cli_cd_codigo_cliente,
       a.mot_cd_matricula,
       a.mot_cd_motorista,
       a.mot_cd_usuario,
       a.mot_nm_motorista,
       a.mot_cpf,
       a.mot_cnt_vl_email,
       a.mot_nm_svc,
       c.Placa as vei_ds_placa ,
       d.tf_nm_tipo_frota,
	   v.vei_in_tipo_frota,
	   v.vei_ds_tipo,
       c.datareferencia AS ultima_data_rota,
       ROW_NUMBER() OVER (PARTITION BY a.mot_cd_motorista ORDER BY c.datareferencia DESC) AS rn
   FROM tb_motorista a WITH(NOLOCK)
   JOIN tb_ml_rotas c WITH(NOLOCK)
       ON a.mot_nm_motorista = c.NomeMotorista
   JOIN tb_tipo_frota d WITH(NOLOCK)
     --  ON b.vei_in_tipo_frota = d.tf_cd_tipo_frota
       on a.mot_cd_cliente = d.tf_cd_cliente
   JOIN tb_clientes e WITH(NOLOCK)
       ON (c.IdTransportadora = e.cli_id_logistics OR c.IdTransportadora = e.cli_id_shopee)
	JOIN tb_veiculos v WITH(NOLOCK)
       ON a.mot_ds_plate = v.vei_ds_placa
  
)
SELECT 
	   cli_cd_codigo_cliente,
       mot_cd_matricula,
       mot_cd_motorista,
       mot_cd_usuario,
       mot_nm_motorista,
       mot_cpf,
       mot_cnt_vl_email,
       mot_nm_svc,
       vei_ds_placa ,
       vei_ds_tipo,
	   vei_in_tipo_frota,
	   tf_nm_tipo_frota,	  
       ultima_data_rota
FROM MotoristaUltimaRota
WHERE rn = 1;


--SELECT distinct
--	e.cli_cd_codigo_cliente,
--	a.mot_cd_matricula,
--	a.mot_cd_motorista,
--	a.mot_cd_usuario,
--    a.mot_nm_motorista,
--    a.mot_cpf,
--    a.mot_cnt_vl_email,
--    a.mot_nm_svc, 
--    b.vei_ds_placa,
--    b.vei_ds_tipo,
--	b.vei_in_tipo_frota,
--	d.tf_nm_tipo_frota,
--    MAX(c.datareferencia) AS ultima_data_rota
--FROM tb_motorista a WITH(NOLOCK)
--JOIN tb_veiculos b WITH(NOLOCK)
--    ON a.mot_ds_plate = b.vei_ds_placa
--JOIN tb_ml_rotas c WITH(NOLOCK)
--    ON a.mot_ds_plate = c.placa
--JOIN tb_tipo_frota D WITH(NOLOCK)
--	ON b.vei_in_tipo_frota = d.tf_cd_tipo_frota
--	and a.mot_Cd_cliente = tf_cd_cliente
--JOIN tb_clientes E with(nolock)
--	on (c.IdTransportadora = e.cli_id_logistics
--	or c.IdTransportadora = e.cli_id_shopee)
--GROUP BY
--	e.cli_cd_codigo_cliente,
--    a.mot_nm_motorista,
--    a.mot_cpf,
--    a.mot_cnt_vl_email,
--    a.mot_nm_svc,
--    a.mot_cd_matricula,
--    a.mot_cd_motorista,
--    a.mot_cd_usuario,
--    b.vei_ds_placa,
--    b.vei_ds_tipo,
--	b.vei_in_tipo_frota,
--	d.tf_nm_tipo_frota;
--GO


GO
