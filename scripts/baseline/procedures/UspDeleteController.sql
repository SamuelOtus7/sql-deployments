-- ============================================================
-- BASELINE: dbo.UspDeleteController
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspDeleteController]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspDeleteController]
(
	@controller int
)
as
delete from tb_logs_acessos where ctr_cd_controller = @controller
delete from tb_favoritos where ctr_cd_controller = @controller
delete a from tb_action_grupo_acesso a join tb_action_controller b on a.aga_cd_action_controller = b.acc_cd_action_controller where b.acc_cd_controller = @controller
delete from tb_action_controller where acc_cd_controller = @controller
delete from tb_crud where crd_cd_controller = @controller
delete from tb_controller where ctr_cd_controller = @controller


GO
