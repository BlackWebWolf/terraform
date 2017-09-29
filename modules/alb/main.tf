# Default ALB implementation that can be used connect ECS instances to it

resource "aws_alb_target_group" "default" {
  name                 = "${var.alb_name}-default"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    path     = "${var.health_check_path}"
    protocol = "HTTP"
  }

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_alb" "alb" {
  name            = "${var.alb_name}"
  subnets         = ["${var.public_subnet_ids}"]
  security_groups = ["${aws_security_group.alb.id}"]

  tags {
    Environment = "${var.environment}"
  }
}


resource "aws_security_group" "alb" {
  name   = "${var.alb_name}_alb"
  vpc_id = "${var.vpc_id}"

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "https_from_anywhere" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["${var.allow_cidr_block}"]
  security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "outbound_internet_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb.id}"
}


resource "aws_alb_target_group" "secondary" {
  count = "${length(var.target_group_names)}"
  name                 = "${var.alb_name}-${lookup(var.target_group_names, count.index)}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    path     = "${var.health_check_path}"
    protocol = "HTTP"
  }

  tags {
    Environment = "${var.environment}"
  }
}


resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.secondary.0.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "terra" {
  count = "${length(var.target_group_names)}"
  listener_arn = "${aws_alb_listener.https.arn}"
  priority     = "10${count.index}"

  action {
    type             = "forward"
    target_group_arn = "${element(aws_alb_target_group.secondary.*.arn, count.index)}"

    # ${element(aws_alb_target_group, count.index)}.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/${lookup(var.target_group_names, count.index)}/"]
  }
}