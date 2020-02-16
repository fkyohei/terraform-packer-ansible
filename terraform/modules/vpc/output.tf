output "vpc_id" {
    value = aws_vpc.main.id
}
output "subnet_public_a_id" {
    value = aws_subnet.public_a.id
}
output "subnet_public_c_id" {
    value = aws_subnet.public_c.id
}
output "subnet_private_a_id" {
    value = aws_subnet.private_a.id
}
output "subnet_private_c_id" {
    value = aws_subnet.private_c.id
}
output "subnet_db_a_id" {
    value = aws_subnet.db_a.id
}
output "subnet_db_c_id" {
    value = aws_subnet.db_c.id
}