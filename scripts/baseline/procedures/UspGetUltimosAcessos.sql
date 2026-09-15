-- ============================================================
-- BASELINE: dbo.UspGetUltimosAcessos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetUltimosAcessos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspGetUltimosAcessos]
(
	@usuario int
)

as

WITH DistinctLogs AS
(
    SELECT
          l.ctr_cd_controller as CodController
        , l.log_dh_acesso as DataHoraAcesso
        , a.act_nm_action           AS ActionName
        , c.ctr_nm_label          AS ControllerName
        , c.ctr_nm_rota           AS Rota
        , c.ctr_nm_rota_params     AS RotaParametros
        , ROW_NUMBER() OVER (
              PARTITION BY l.ctr_cd_controller
              ORDER BY l.log_dh_acesso DESC
          ) AS rn
    FROM tb_logs_acessos l
    INNER JOIN tb_action a 
        ON l.act_cd_action = a.act_cd_action
    INNER JOIN tb_controller c
        ON l.ctr_cd_controller = c.ctr_cd_controller
    WHERE l.usr_cd_usuario = @usuario
)
SELECT TOP 10
      CodController
    , DataHoraAcesso
    , ActionName
    , ControllerName
    , Rota
    , RotaParametros
FROM DistinctLogs
WHERE rn = 1
ORDER BY DataHoraAcesso DESC;
GO
