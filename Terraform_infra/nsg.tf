resource "aws_security_group" "kubernetes_controlplane" {
  name        = "ctlplane_sg"
  description = "Allow SSH and necessary ports for k8s cluster - ctlplane"
  vpc_id      = aws_vpc.main_vpc.id 
}