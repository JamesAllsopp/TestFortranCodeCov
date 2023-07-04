##JA - This is code I've hacked out of the main Makefile to try and build the tests

module purge
module load bear-apps/2021b
module load foss/2021b
which gfortran
module load CMake/3.22.1-GCCcore-11.2.0
module load Python/3.9.6-GCCcore-11.2.0
module load Ruby/3.0.1-GCCcore-11.2.0

FORT_COMP="gfortran"
CVODELIB="${HOME}/atchem-lib/cvode/lib"
OPENLIBMDIR="${HOME}/atchem-lib/openlibm-0.8.1"
FRUITDIR="${HOME}/atchem-lib/fruit_3.4.3"

RPATH_OPTION="-R" 
 
FFLAGS="-O2 -fprofile-arcs -ftest-coverage -ffree-form -fimplicit-none -Wall -Wpedantic -fcheck=all -fPIC"
 
 LDFLAGS="-L${CVODELIB} -L${OPENLIBMDIR} -Wl,${RPATH_OPTION},/usr/lib/:${CVODELIB}:${OPENLIBMDIR} -lopenlibm -lsundials_fcvode -lsundials_cvode -lsundials_fnvecserial -lsundials_nvecserial -ldl"
 
SRC="src"
OBJ="obj"

if [ ! -d "${OBJ}" ]; then
  mkdir ${OBJ}
fi


UNITTESTDIR="tests/unit_tests"
fruit_code="${FRUITDIR}/src/fruit.f90"

UNITTEST_SRCS="${SRC}/dataStructures.f90 ${SRC}/solarFunctions.f90"
SRCS="${UNITTEST_SRCS} ${SRC}/atchem2.f90"

unittest_code="${UNITTEST_SRCS} $(ls tests/unit_tests/*_test.f90 )"
unittest_code_gen="${UNITTESTDIR}/fruit_basket_gen.f90 ${UNITTESTDIR}/fruit_driver_gen.f90"
all_unittest_code="${fruit_code} ${unittest_code} ${unittest_code_gen}"
fruit_driver="${UNITTESTDIR}/fruit_driver.exe"

cp tests/fruit_generator.rb ${UNITTESTDIR}
cd ${UNITTESTDIR}
sed -i "18s,.*,load \"${FRUITDIR}/rake_base.rb\"," fruit_generator.rb
ruby fruit_generator.rb     # This is the line

# build fruit_driver.exe from the individual unit tests
all_unittest_code="${fruit_code} ${unittest_code} ${unittest_code_gen}"
cd ../..
${FORT_COMP} -o ${fruit_driver} -J${OBJ} -I${OBJ} ${all_unittest_code} ${FFLAGS} ${LDFLAGS}

${fruit_driver}
