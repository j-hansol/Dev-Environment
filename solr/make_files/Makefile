TARGET=MeCab
JAVAC=javac
JAVA=java
JAR=jar
CXX=c++
INCLUDE=/usr/lib/jvm/java-8-openjdk-amd64/include

PACKAGE=org/chasen/mecab

LIBS=`mecab-config --libs`
INC=`mecab-config --cflags` -I$(INCLUDE) -I$(INCLUDE)/linux

all:
	$(CXX) -O1 -c -fpic $(TARGET)_wrap.cxx  $(INC)
	$(CXX) -shared  $(TARGET)_wrap.o -o lib$(TARGET).so $(LIBS)
	$(JAVAC) $(PACKAGE)/*.java
	$(JAR) cfv $(TARGET).jar $(PACKAGE)/*.class

clean:
	rm -fr *.jar *.o *.so *.class $(PACKAGE)/*.class
        
cleanall:
	rm -fr $(TARGET).java *.cxx
