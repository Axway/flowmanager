provider "kubernetes" {
}

provider "helm" {
  kubernetes {
  }
}

provider "random" {
}