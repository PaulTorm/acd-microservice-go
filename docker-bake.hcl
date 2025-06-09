group "default" {
  targets = [
    "frontend",
    "gateway",
    "student",
    "exam",
    "translation",
    "exam-management",
  ]
}

target "frontend" {
  context = "./frontend"
  dockerfile = "Dockerfile"
  tags = ["frontend:latest"]
}

target "gateway" {
  context = "./services/gateway"
  dockerfile = "Dockerfile"
  tags = ["gateway:latest"]
}

target "student" {
  context = "./services/student"
  dockerfile = "Dockerfile"
  tags = ["student:latest"]
}

target "exam" {
  context = "./services/exam"
  dockerfile = "Dockerfile"
  tags = ["exam:latest"]
}

target "translation" {
  context = "./services/translation"
  dockerfile = "Dockerfile"
  tags = ["translation:latest"]
}

target "exam-management" {
  context = "./services/exam-management"
  dockerfile = "Dockerfile"
  tags = ["exam-management:latest"]
}
