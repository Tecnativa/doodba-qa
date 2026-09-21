variable "IMAGE_NAME" {
  default = "tecnativa/doodba-qa"
}

variable "TAG" {
 default = "testonly"
}
variable "SUFFIX" {
 default = ""
}

group "default" {
  targets = [
    "testing"
  ]
}

variable "PLATFORMS" {
    default = ""
}

target "testing" {
  tags = [
    "${IMAGE_NAME}:${TAG}${SUFFIX}"
  ]
  context = "."
  dockerfile = "Dockerfile"
  platforms = split(",", PLATFORMS)
}
