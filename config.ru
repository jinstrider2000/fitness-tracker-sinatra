require './config/environment'

use Rack::Flash
use UserController
use ExerciseController
use FoodController
run ApplicationController