import Base
import ./LAWS.bend as Laws

# GREEN, then REFACTOR (see README.md).

# LEMMA (pure algebra): the three pairwise differences cancel.
# This is d^2 = 0 on the face: curl of a gradient always vanishes.
# (Same shape as d2-zero's xor_cancel3, restated here so this
# folder is self-contained; the duplication is a packaging TODO.)
def grad_curl_cancel(+x: Bool, +y: Bool, +z: Bool)
  -> {Laws.curl_of_grad(x, y, z) == False{} : Bool}:
  match x:
    case True{}:
      match y:
        case True{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}
        case False{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}
    case False{}:
      match y:
        case True{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}
        case False{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}

# LEMMA (pure algebra): on the tetrahedron, every one of the 6 edges
# borders exactly 2 of the 4 faces, so each edge value appears twice
# in the XOR and cancels. Brute force over 2^6 = 64 cases.
def curl_div_cancel(+e01: Bool, +e02: Bool, +e03: Bool, +e12: Bool, +e13: Bool, +e23: Bool)
  -> {Laws.div_of_curl(e01, e02, e03, e12, e13, e23) == False{} : Bool}:
  match e01:
    case True{}:
      match e02:
        case True{}:
          match e03:
            case True{}:
              match e12:
                case True{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                case False{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
            case False{}:
              match e12:
                case True{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                case False{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
        case False{}:
          match e03:
            case True{}:
              match e12:
                case True{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                case False{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
            case False{}:
              match e12:
                case True{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                case False{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
    case False{}:
      match e02:
        case True{}:
          match e03:
            case True{}:
              match e12:
                case True{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                case False{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
            case False{}:
              match e12:
                case True{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                case False{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
        case False{}:
          match e03:
            case True{}:
              match e12:
                case True{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                case False{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
            case False{}:
              match e12:
                case True{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                case False{}:
                  match e13:
                    case True{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}
                    case False{}:
                      match e23:
                        case True{}:
                          {==}
                        case False{}:
                          {==}

# LEMMA (pure algebra): div(grad f) agrees with the Laplacian read
# under the opposite orientation convention -- i.e. the discrete
# Laplacian is well-defined, independent of how you orient the edges.
def div_grad_laplacian(+x: Bool, +y: Bool, +z: Bool)
  -> {Laws.div_of_grad(x, y, z) == Laws.laplacian(x, y, z) : Bool}:
  match x:
    case True{}:
      match y:
        case True{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}
        case False{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}
    case False{}:
      match y:
        case True{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}
        case False{}:
          match z:
            case True{}:
              {==}
            case False{}:
              {==}
