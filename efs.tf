resource "aws_efs_file_system" "efs" {
  creation_token = "efs-for-eks"
}

resource "aws_efs_mount_target" "efs_mount" {
  count          = length(aws_subnet.pri_sub)
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.pri_sub[count.index].id
}

