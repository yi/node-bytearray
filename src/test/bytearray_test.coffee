
require 'mocha'
should =  require 'should'

bytearray = require '../byteArray'

FIXTURE_UTF = "这个LED花洒有意思，@陈中 可建议 @吴海 在桔子酒店引入，"
FIXTURE_UTF_LENGTH = FIXTURE_UTF.length
FIXTURE_UTF_BYTE_LENGTH = Buffer.byteLength(FIXTURE_UTF)
FIXTURE_UTF_BUFF = new Buffer(2 + FIXTURE_UTF_BYTE_LENGTH)
FIXTURE_UTF_BUFF.writeUInt16BE( FIXTURE_UTF_BYTE_LENGTH, 0)
FIXTURE_UTF_BUFF.write(FIXTURE_UTF, 2)


VECTOR_UINT_1 = [4196330,4196812,4198245,4198550,4196885,4197941,4197659,4196640,4196980,4196368,4196795,4197527,4196374,4196672,4197016,4197661,4197014,4197449,4197615,4196330,4196579,4196714,4196835,4196808,4196786,4197947,4196473,4196646,4197939,4197928,4196366,4197926,4197559,4196333,4198850,4196840,4197927,4196511,4197938,4196812,4197925,4197526,4196312,4196804,4197528,4196682,4196954,4196409,4196258,4198177,4196291,4198245,4198180,4196216,4198277,4196263,4198280,4198276,4198282,4198201,4198279,4197004,4198211,4197011,4196759,4197097,4196512,4197018,4198236,4198304,4196397,4198237,4198312,4198198,4198199,4198259,4198310,4198305,4197201,4198160,4198326,4198189,4197704,4197257,4198311,4197475,4198283,4198222,4196299,4198250,4198230,4196996,4198149,4198315,4197312,4198327,4199252,4198181,4198221,4198316,4198154,4198244,4196920,4196943,4198325,4198320,4196975,4198249]

VECTOR_UINT_STR_1 = ["4196330","4196812","4198245","4198550","4196885","4197941","4197659","4196640","4196980","4196368","4196795","4197527","4196374","4196672","4197016","4197661","4197014","4197449","4197615","4196330","4196579","4196714","4196835","4196808","4196786","4197947","4196473","4196646","4197939","4197928","4196366","4197926","4197559","4196333","4198850","4196840","4197927","4196511","4197938","4196812","4197925","4197526","4196312","4196804","4197528","4196682","4196954","4196409","4196258","4198177","4196291","4198245","4198180","4196216","4198277","4196263","4198280","4198276","4198282","4198201","4198279","4197004","4198211","4197011","4196759","4197097","4196512","4197018","4198236","4198304","4196397","4198237","4198312","4198198","4198199","4198259","4198310","4198305","4197201","4198160","4198326","4198189","4197704","4197257","4198311","4197475","4198283","4198222","4196299","4198250","4198230","4196996","4198149","4198315","4197312","4198327","4199252","4198181","4198221","4198316","4198154","4198244","4196920","4196943","4198325","4198320","4196975","4198249"]


UNIT_ARR = [1,2,3,4,5,6,0xfffffff1, 0xfffffff2]

describe 'bytearray', ->

  it 'should read/write dynamic length utf correctly', ->
    buf = new Buffer(2 + FIXTURE_UTF_BYTE_LENGTH)
    bytearray.writeUTF(buf, FIXTURE_UTF)
    #console.log "[bytearray_test::] buf:#{buf.toString('hex')}"
    buf.toString('hex').should.eql(FIXTURE_UTF_BUFF.toString('hex'))
    #console.log "[bytearray_test::] bytearray.readUTF(buf, 0):#{bytearray.readUTF(buf, 0)}"
    bytearray.readUTF(buf, 0).should.eql(FIXTURE_UTF)

  it 'should conver utf string to buffer correctly', ->
    str = "中午侧阿凡达是否违反片假名ニホンゴ，罗马音nihon go  将（ المنهج الواضح لتعل&#..."
    byteLength = Buffer.byteLength(str)
    buf = bytearray.utfStringToBuf(str)
    bytearray.readUnsignedShort(buf,0).should.eql(byteLength)
    console.log "[bytearray_test::test utfStringToBuf] buf:#{buf.toString('hex')}"
    buf.slice(2).toString('hex').should.eql((new Buffer(str)).toString('hex'))

  it 'should able to write/read an uint vector', ->
    buf = new Buffer(VECTOR_UINT_1.length * 4 + 2)
    bytearray.writeUnsignedIntArray(buf, VECTOR_UINT_1)
    arr = bytearray.readUnsignedIntArray(buf, 0)
    console.log "[bytearray_test::write/read an uint vector] arr:#{arr}"
    arr.join(',').should.eql(VECTOR_UINT_1.join(','))

  it 'should able to write/read an string vector as an uint vector', ->
    buf = new Buffer(VECTOR_UINT_STR_1.length * 4 + 2)
    bytearray.writeUnsignedIntArray(buf, VECTOR_UINT_STR_1)
    arr = bytearray.readUnsignedIntArray(buf, 0)
    console.log "[bytearray_test::write/read an uint vector] arr:#{arr}"
    arr.join(',').should.eql(VECTOR_UINT_1.join(','))

  it 'should read and write UTFBytes correctly' , ->
    str = "hellow, how are you"
    byteLength = Buffer.byteLength(str)
    buf = new Buffer byteLength
    bytearray.writeUTFBytes buf, str
    buf2 = new Buffer str
    buf.toString('hex').should.equal(buf2.toString('hex'))
    buf.position.should.equal(byteLength)
    bytearray.readUTFBytes(buf, byteLength, 0).should.equal str

  it 'should read and write Float correctly' , ->
    sample = [321.324241, 0.323131, 4242.5435, 0.43242342]
    buf = new Buffer sample.length * 4
    for i in [0...sample.length] by 1
      bytearray.writeFloat buf, sample[i]

    buf.position = 0

    for i in [0...sample.length] by 1
      orgin = sample[i]
      readback = bytearray.readFloat(buf)
      console.log "[bytearray_test::Float test] orgin:#{orgin}, readback:#{readback}"
      Math.abs(readback - orgin).should.below(0.01)










