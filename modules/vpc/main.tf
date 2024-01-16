data "aws_availability_zones" "available" {
  state = "available"
}


locals {
    azs = data.aws_availability_zones.available.names
    default_tags = {
        # Name        = "${var.identifier}-${terraform.workspace}"
        Environment = "${terraform.workspace}"
        ManagedBy   = "Terraform"
    }
    #Defaults tags with the custom tags passed by users
    tags = "${merge(local.default_tags, var.tags)}"

    #multi nat configs
    multi_nat = var.multi_nat_gw ? local.az_count : 1
    az_count  = length(var.public_subnets) > length(data.aws_availability_zones.available.names) ? length(data.aws_availability_zones.available.names) : length(var.public_subnets)


}
#VPC
resource "aws_vpc" "vpc" {
 cidr_block       = var.vpc_cidr
 instance_tenancy = "default"
 enable_dns_support = var.enable_dns_support
 enable_dns_hostnames = var.enable_dns_hostnames

 tags = merge(local.tags, {Name = "${var.identifier}-${terraform.workspace}"})
}

#Subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = element(local.azs, count.index)

  tags = merge(local.tags, {Name = "${var.identifier}-${terraform.workspace}-public-subnet-${count.index}"})
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.private_subnets, count.index)
  availability_zone = element(local.azs, count.index)

  tags = merge(local.tags, {Name = "${var.identifier}-${terraform.workspace}-private-subnet-${count.index}"})
}
resource "aws_subnet" "data_subnets" {
  count = length(var.data_subnets)
  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.data_subnets, count.index)
  availability_zone = element(local.azs, count.index)

  tags = merge(local.tags, {Name = "${var.identifier}-${terraform.workspace}-data-subnet-${count.index}"})
  
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, {Name = "${var.identifier}-${terraform.workspace}-igw"})
  
}


#NAT Gateway
resource "aws_eip" "nat_gw" {
  # count = length(var.nat_eip) > 0 ? 0 : local.multi_nat
  count = local.multi_nat
  tags  = merge(local.tags, {Name = "${var.identifier}-${terraform.workspace}-nat-eip"})
  domain   = "vpc"

  depends_on = [aws_subnet.private_subnets, aws_subnet.data_subnets]
}


resource "aws_nat_gateway" "nat_gw" {
  count         = local.multi_nat
  # allocation_id = length(var.nat_eip) > 0 ? data.aws_eip.user_eips[count.index].id : aws_eip.nat_gw[count.index].id
  allocation_id = aws_eip.nat_gw[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  tags          = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-nat-gw-${count.index}" })

  depends_on = [aws_subnet.private_subnets, aws_subnet.data_subnets, aws_subnet.public_subnets]
}

#Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-public" })
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-private-${count.index}" })
}

resource "aws_route_table" "data_subnets" {
  count  = length(var.data_subnets)
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.tags, { Name = "${var.identifier}-${terraform.workspace}-data-${count.index}" })
}

#route table association
resource "aws_route_table_association" "public_subnet" {
  count          = length(var.public_subnets)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_route_table_association" "private_subnets" {
  count          = length(var.private_subnets)
  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

resource "aws_route_table_association" "data_subnets" {
  count          = length(var.data_subnets)
  route_table_id = aws_route_table.data_subnets[count.index].id
  subnet_id      = aws_subnet.data_subnets[count.index].id
}

## Default Route definition per layer
resource "aws_route" "internet_gateway_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public.id
  depends_on             = [aws_route_table.public]
}

resource "aws_route" "private_nat_gateway_route" {
  count                  = length(var.private_subnets)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index % local.multi_nat].id
  route_table_id         = aws_route_table.private[count.index].id
  depends_on             = [aws_route_table.private]
}

resource "aws_route" "data_nat_gateway_route" {
  count                  = length(var.data_subnets)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index % local.multi_nat].id
  route_table_id         = aws_route_table.data_subnets[count.index].id
  depends_on             = [aws_route_table.data_subnets]
}