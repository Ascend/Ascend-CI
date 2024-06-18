# ONNXRuntime支持昇腾设计说明

## 1. 概述

Open Neural Network Exchange (ONNX) 作为一个开放的生态系统，为人工智能开发人员提供了极大的灵活性，使他们能够根据项目需求选择合适的工具，而无需被特定的框架或生态系统所限制。ONNX的核心价值在于其互操作性，它简化了从研究到生产之间的转化过程，使得模型能够在不同的框架之间无缝迁移。

ONNXRuntime（ORT）作为ONNX模型的官方推理引擎，原生支持ONNX模型，并以其高效、稳定和易于集成的特性，逐渐成为通用推理平台的事实标准。ORT支持多种编程语言，包括C++、Python、Java和JavaScript等，且兼容多种AI加速设备，如GPU、CPU和特定的硬件加速器。

### 1.1 当前现状

在当前的AI开源生态中，框架多样性和模型格式的复杂性使得用户面临诸多挑战。不同的训练框架和推理框架之间缺乏统一的接口和标准，导致用户在从训练到推理的过程中需要频繁地进行模型转换和适配，增加了工作量和难度。

对于昇腾（Ascend）这样的特定硬件平台，其开源软件领域的适配度相对较低，难以融入繁荣的AI开源生态。目前，用户如果想在昇腾上使用ONNX模型，需要先使用昇腾提供的工具进行模型转换，这不仅增加了用户的操作复杂度，还可能导致性能损失和兼容性问题。

### 1.2 解决方案

为了解决上述问题，我们提出了在ONNXRuntime中原生支持昇腾后端的解决方案。这一方案旨在实现以下目标：

1. **简化用户操作**：用户无需进行额外的模型转换，即可直接在ONNXRuntime+昇腾上运行ONNX模型，大大降低了操作复杂度。
  
2. **提高兼容性**：通过原生支持昇腾后端，确保ONNX模型在昇腾平台上的兼容性和性能。

3. **降低适配成本**：一劳永逸地满足用户对昇腾推理场景的需求，降低了昇腾平台的适配成本。

## 2. 详细设计

### 2.1 整体架构

ONNXRuntime官方提供了一套完善的后端接入框架，并且已经支持了大量的AI加速设备，昇腾可以直接作为一个新的后端接入，ORT的后端机制叫做Execution Provider（EP），可以将多个设备同时注册到ONNXRuntime中，使用时会根据指定的后端优先级顺序进行算子分配，不支持的算子会回退到CPU上，如下图所示：

```
┌─────────────────────────────────────────┐
│               ONNXRuntime               │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│             Execution Provider          │
└───┬─────────┬───────────┬──────────┬────┘
    │         │           │          │
    │         │           │          │
┌───▼──┐ ┌────▼───┐ ┌─────▼────┐ ┌───▼────┐
│ CUDA │ │ CoreML │ │ openVINO │ │  CANN  │
└───┬──┘ └────┬───┘ └─────┬────┘ └───┬────┘
    │         │           │          │
┌───▼──┐ ┌────▼───┐ ┌─────▼────┐ ┌───▼────┐
│ GPU  │ │  Apple │ │  Intel   │ │ Ascend │
└──────┘ └────────┘ └──────────┘ └────────┘
```
### 2.2 接口设计

ONNXRuntime北向支持多种编程语言，包括C++、Python、Java、JavaScript等等。其中C++是核心API，其他语言是基于C++做上层高级封装，Ascend NPU目前只考虑支持C++以及Python。如下所示：
```
┌────────┐ ┌──────┐ ┌────────────┐
│ Python │ │ Java │ │ JavaScript │
└───┬────┘ └───┬──┘ └──────┬─────┘
    │          │           │
┌───▼──────────▼───────────▼─────┐
│              C++               │
└───────────────┬────────────────┘
                │
┌───────────────▼────────────────┐
│        ONNXRuntime API         │
└────────────────────────────────┘
```
### Ascend NPU新增的C++接口如下所示：

- SessionOptionsAppendExecutionProvider_CANN
- CreateCANNProviderOptions
- UpdateCANNProviderOptions
- GetCANNProviderOptionsAsString
- ReleaseCANNProviderOptions

1. SessionOptionsAppendExecutionProvider_CANN
   - 描述：Append CANN provider to session options，If CANN is not available (due to a non CANN enabled build, or if CANN is not installed on the system), this function will return failure.
   - 参数IN：options
   - 参数IN：cann_options

2. CreateCANNProviderOptions
   - 描述：Create an OrtCANNProviderOptions，
   - 参数OUT: ::OrtCANNProviderOptions. Must be released with OrtApi::ReleaseCANNProviderOptions

3. UpdateCANNProviderOptions
   - 描述：Set options in a CANN Execution Provider.
   - 参数IN：cann_options
   - 参数IN：provider_options_keys Array of UTF-8 null-terminated string for provider options keys
   - 参数IN：provider_options_values Array of UTF-8 null-terminated string for provider options values
   - 参数IN：num_keys Number of elements in the `provider_option_keys` and `provider_options_values` arrays

4. GetCANNProviderOptionsAsString
   - 描述：Get serialized CANN provider options string.
   - 参数IN：cann_options OrtCANNProviderOptions instance
   - 参数IN：allocator a ptr to an instance of OrtAllocator obtained with CreateAllocator()
                        or GetAllocatorWithDefaultOptions(), the specified allocator will be used to allocate
                        continuous buffers for output strings and lengths.
   - 参数OUT：ptr is a UTF-8 null terminated string allocated using 'allocator'.
                The caller is responsible for using the same allocator to free it.

5. ReleaseCANNProviderOptions
   - 描述：Release an OrtCANNProviderOptions
   - 参数IN：the pointer of OrtCANNProviderOptions which will been deleted

### CANNOption定义如下：

```C++
struct OrtCANNProviderOptions {
  int device_id;                                           // CANN device id
  int max_opqueue_num;                                     // CANN operator cache information aging configuration
  size_t npu_mem_limit;                                    // BFC Arena memory limit for CANN
  onnxruntime::ArenaExtendStrategy arena_extend_strategy;  // Strategy used to grow the memory arena
  int do_copy_in_default_stream;                           // Flag indicating if copying needs to take place on the
                                                           // same stream as the compute stream in the CANN EP
  OrtArenaCfg* default_memory_arena_cfg;                   // CANN memory arena configuration parameters
};
```

昇腾EP支持的Option有：
- **device_id**：The device ID.

     Default value: 0
- **npu_mem_limit**：设备内存的大小限制（以字节为单位）。此大小限制仅适用于执行提供程序的内存。
- **arena_extend_strategy**：扩展设备内存领域的策略。

     Value：
     - kNextPowerOfTwo
     - kSameAsRequested
- **enable_cann_graph**：是否使用图推理引擎来提高性能。建议设置为true。如果为false，则它将回退到单运算符推理引擎。

     Default value: true
- **dump_graphs**：是否将子图转储为onnx格式，用于子图分割分析。
- **precision_mode**：运算符的精度模式。

     Value：
     - force_fp32/cube_fp16in_fp32out
     - force_fp16
     - allow_fp32_to_fp16
     - must_keep_origin_dtype
     - allow_mix_precision/allow_mix_precision_fp16	
- **op_select_impl_mode**：CANN中的一些内置运算符具有高精度和高性能的实现，设置使用的模式。

     Value：
     - high_precision
     - high_performance
- **optypelist_for_implmode**：使用op_select_impl_mode的算子列表。

     Value：
     - Pooling
     - SoftmaxV2
     - LRN
     - ROIAlign
- **dump_om_model**: Whether to dump the offline model for Ascend AI Processor to an .om file.

    Default value: true

### 2.3 后端设计

ONNXRuntime主要支持模型推理能力，但目前也在不断增强模型训练的接口和能力，本设计主要实现昇腾推理的功能，同时预留昇腾训练支持的能力。如下所示：

```
┌──────────────────────────────┐
│         ONNXRuntime          │
└──────────────┬───────────────┘
               │
┌──────────────▼───────────────┐
│            CANN              │
└──────┬────────────────┬──────┘
       │                │
┌──────▼────┐     ┌─────▼──────┐
│ Inference │     │    Train   │
└──────┬────┘     └──────────┬─┘
       │                     │
       ├────────────────┐    │(Reserved)
       │                │    │
┌──────▼─────┐    ┌─────▼────▼─┐
│ Ascend 310 │    │ Ascend 910 │
└────────────┘    └────────────┘
```

### 2.4 功能设计

ONNXRuntime Execution Provider本身还要支持以下功能：

- 算子注册（具体注册细节相见 ONNXRuntime.xmind)

  ONNX算子有版本的概念，例如Add算子有1,6,7,13,14几个版本。ONNXRuntime对后端提供了算子注册功能，每个后端可以根据自己支持的算子情况，向上注册算子支持列表。昇腾针对ONNX算子无法全量支持，有一定的版本要求，因此在实现本特性的时候，需要注意算子注册的种类以及内容。以`AveragePool`为例，昇腾后端支持的类型及版本如下，都需要在ONNXRuntime中一一注册：
  
  ```C++
  REGISTER_POOL_VERSIONED_TYPED_KERNEL(AveragePool, float, 7, 9)
  REGISTER_POOL_VERSIONED_TYPED_KERNEL(AveragePool, MLFloat16, 7, 9)
  REGISTER_POOL_VERSIONED_TYPED_KERNEL(AveragePool, float, 10, 10)
  REGISTER_POOL_VERSIONED_TYPED_KERNEL(AveragePool, MLFloat16, 10, 10)
  REGISTER_POOL_TYPED_KERNEL(AveragePool, float, 11)
  REGISTER_POOL_TYPED_KERNEL(AveragePool, MLFloat16, 11)
  ```

- 算子实现

  ONNX包含算子130+，昇腾后端理论上需要全部支持，按照特性开发计划，优先实现最核心的算子，以ONNXRuntime model zoo中的模型为参考，包括如下算子：
  
  ```C++
  ai.onnx:Abs
  ai.onnx:Add
  ai.onnx:AveragePool（Only 2D Pool is supported.）
  ai.onnx:BatchNormalization
  ai.onnx:Cast
  ai.onnx:Ceil
  ai.onnx:Conv（Only 2D Conv is supported.Weights and bias should be constant.）
  ai.onnx:Cos
  ai.onnx:Div
  ai.onnx:Dropout
  ai.onnx:Exp
  ai.onnx:Erf
  ai.onnx:Flatten
  ai.onnx:Floor
  ai.onnx:Gemm
  ai.onnx:GlobalAveragePool
  ai.onnx:GlobalMaxPool
  ai.onnx:Identity
  ai.onnx:Log
  ai.onnx:MatMul
  ai.onnx:MaxPool（Only 2D Pool is supported）
  ai.onnx:Mul
  ai.onnx:Neg
  ai.onnx:Reciprocal
  ai.onnx:Relu 
  ai.onnx:Reshape
  ai.onnx:Round
  ai.onnx:Sin
  ai.onnx:Sqrt
  ai.onnx:Sub
  ai.onnx:Transpose
  ```
  
- 算子融合

  ONNXRuntime本身支持3级模型优化，其中包括算子融合的步骤，这一步需要根据昇腾本身的硬件能力来决定，比如多个ADD算子可以融合成一个Mul算子。这个能力本特性需要对外暴露，具体的融合策略支持用户自定义或者提供一些简单的融合规则。

  设计原则：
  
  **性能优化：**算子融合的主要目的是提高模型的推理速度和效率，减少计算和内存开销。
  
  **资源利用：**通过将多个相邻且可融合的算子合并为一个更大的算子，以减少计算资源的浪费。
  
  **减少内存传输：**融合算子可以减少中间结果的存储和传输，从而降低内存占用和数据传输成本。
  
  **简化计算图：**算子融合可以简化计算图结构，提高模型的可读性和维护性。
  
  算子融合流程：
  
  **算子识别：**识别模型中相邻且可融合的算子，例如多个相同类型的算子或支持融合的特定算子。

  **融合规则：**制定算子融合规则，确定哪些算子可以被融合以及如何进行融合。
  
  **算子合并：**根据融合规则，将相邻的可融合算子合并为一个更大的算子。
  
  **优化检查：**检查融合后的算子是否仍然满足模型的需求，并确保推理结果的准确性。
  
  **性能评估：**评估融合后模型的推理性能，比较融合前后的计算速度和资源利用情况。
  
  **调整参数：**根据性能评估结果调整融合规则和参数，进一步优化模型的推理性能。
  
  **持续优化：**持续监控模型的推理性能，根据实际情况调整算子融合策略，保持模型的最佳性能状态。

  目前Ascend NPU仅支持一下几种算子融合：
  
  - 卷积&激活融合
  - 卷积&池化融合
  - BN融合

- 算子同步

  模型中的算子本身涉及依赖关系，比如算子A的输入是算子B的输出，这种场景下算子A需要等待算子B执行完后才可以开始运行。在算子并行场景下，更需要注意这种依赖关系，这里称作算子同步。算子同步场景下，算子的依赖关系也要考虑在内，这样才能不破坏模型的基本能力并且高效生成并行拓扑。

  ONNX Runtime提供了并行执行能力，按照架构需要实现以下对应功能即可：
  - 集成 `Notification` 实现Ascend通知类
    - `Activate`
    - `wait_on_device`
    - `wait_on_host`
  - 集成 Stream 实现 Ascend 流管理
    - `CreateNotification`
    - `Flush`
  - `RegisterCannStreamHandles`
  - `WaitCannNotificationOnDevice`

- 图运行

  模型在推理过程中一般支持两种运行方式，算子运行或图运行。图运行是指把模型整图下发到AI加速设备，设备再返回推理结果的过程。模型的所有解析、拆分都由后端完成，图运行的速度往往优于算子运行模型，但对后端硬件有较强要求，需要后端对算子的支持度

  Ascend NPU本身就支持图运行模型，并且提供了一下接口来实现：
  - `aclgrphParseONNXFromMem`
  - `aclgrphBuildInitialize`
  - `aclgrphBuildModel`
  - `aclgrphSaveModel`
  - `aclgrphBuildFinalize`

  同时 ONNXRuntime 框架本身同时支持图运行和单算子，只需要在 GetCapablities 中返回支持的子图的连续拓扑排序列表即可

- 图分割

  当用户需要运行的模型中包含后端硬件无法执行的算子节点时，为了最大化满足图运行的方式，就要进行图分割操作。以昇腾为例，昇腾CANN本身不支持ConvInteger、DFT等ONNX算子 ，如果用户的输入模型包含了这类算子，就需要进行图切割，把图分成A-B-C三块，其中A、C是支持昇腾的子图，继续运行在昇腾设备上，B是昇腾不支持的子图，运行在其他如CPU后端上即可。

  另外一种场景是用户输入的模型太大，超过了单个昇腾硬件所支持的大小，则需要对用户的大模型进行切分，分成若干个在昇腾允许范围内的子图，再下发到昇腾硬件上进行推理。

  Ascend NPU 本身缺少对表 Nvidia 对应的支持算子列表API，与Ascend ONNX算子团队讨论后，得到如下支持列表

  ```Text
  "Abs", "Acos", "Acosh", "Add",
  "And", "ArgMax", "ArgMin", "Asin",
  "Asinh", "Atan", "Atanh", "AveragePool",
  "BatchNormalization", "BitShift", "Cast", "Ceil",
  "Celu", "Clip", "Compress", "Concat",
  "Constant", "ConstantOfShape", "Conv", "ConvTranspose",
  "Cos", "Cosh", "CumSum", "DepthToSpace",
  "Det", "Div", "Dropout", "Elu",
  "Equal", "Erf", "Exp", "Expand",
  "EyeLike", "Flatten", "Floor", "Gather",
  "GatherElements", "GatherND", "Gemm", "GlobalAveragePool",
  "GlobalLpPool", "GlobalMaxPool", "Greater", "GreaterOrEqual",
  "Hardmax", "HardSigmoid", "HardSwish", "Identity",
  "If", "InstanceNormalization", "LeakyRelu", "Less",
  "LessOrEqual", "Log", "LogSoftmax", "LpNormalization",
  "LpPool", "LRN", "LSTM", "MatMul",
  "Max", "MaxPool", "MaxRoiPool", "MaxUnpool",
  "Mean", "MeanVarianceNormalization", "Min", "Mod",
  "Mul", "Multinomial", "Neg", "NonMaxSuppression",
  "NonZero", "Not", "OneHot", "Or",
  "Pad", "Pow", "PRelu", "RandomNormalLike",
  "RandomUniform", "RandomUniformLike", "Range", "Reciprocal",
  "ReduceL1", "ReduceL2", "ReduceLogSum", "ReduceLogSumExp",
  "ReduceMax", "ReduceMean", "ReduceMin", "ReduceProd",
  "ReduceSum", "ReduceSumSquare", "Relu", "Reshape",
  "Resize", "ReverseSequence", "RoiAlign", "Round",
  "Scatter", "ScatterElements", "ScatterND", "Selu",
  "Shape", "Shrink", "Sigmoid", "Sign",
  "Sin", "Sinh", "Size", "Slice",
  "Softmax", "SoftmaxCrossEntropyLoss", "Softplus", "Softsign",
  "SpaceToDepth", "Split", "Sqrt", "Squeeze",
  "Sub", "Sum", "Tanh", "TfIdfVectorizer",
  "ThresholdedRelu", "Tile", "TopK", "Transpose",
  "Unsqueeze", "Where", "Xor"
  ```
  按照上述算子列表进行图分割，支持的连续>5算子经由图运行，剩下的经由CPU执行。

- 内存管理

  昇腾设备本身包含自己的处理单元和内存，其中内存中存储了当前计算的算子或整图。在计算前与计算后，需要把相关的数据在主机和昇腾设备之间来回拷贝，这就涉及到了内存管理。本特性需要实现对应的内存拷贝接口`do_copy_in_default_stream`。

  ONNXRuntime提供了默认内存管理策略，只需要实现Allocator中的函数即可：

  - `allocator`
  - `free`
  - `pin_allocator`
  - `pin_free`

- 数据搬移

  ONNXRuntime提供I/O binding功能，满足用户session数据到device的直接拷贝，避免了CPU中转，利用I/O绑定功能可以避免输入和输出上的副本产生的开销。

## 3. Ascend CANN Examples


### C++ Example

```C++
const static OrtApi *g_ort = OrtGetApiBase()->GetApi(ORT_API_VERSION);

OrtSessionOptions *session_options;
g_ort->CreateSessionOptions(&session_options);

OrtCANNProviderOptions *cann_options = nullptr;
g_ort->CreateCANNProviderOptions(&cann_options);

std::vector<const char *> keys{"device_id", "npu_mem_limit", "arena_extend_strategy", "enable_cann_graph"};
std::vector<const char *> values{"0", "2147483648", "kSameAsRequested", "1"};

g_ort->UpdateCANNProviderOptions(cann_options, keys.data(), values.data(), keys.size());

g_ort->SessionOptionsAppendExecutionProvider_CANN(session_options, cann_options);

// Finally, don't forget to release the provider options and session options
g_ort->ReleaseCANNProviderOptions(cann_options);
g_ort->ReleaseSessionOptions(session_options);
```

### Python Example

Python接口只需要使用`pybind11`库，配置好python与C++接口映射关系即可，Python代码会自动生成。对应的代码流程也十分简单：

```
import onnxruntime as ort

model_path = '<path to model>'

options = ort.SessionOptions()

providers = [
    (
        "CANNExecutionProvider",
        {
            "device_id": 0,
            "arena_extend_strategy": "kNextPowerOfTwo",
            "npu_mem_limit": 2 * 1024 * 1024 * 1024,
            "op_select_impl_mode": "high_performance",
            "optypelist_for_implmode": "Gelu",
            "enable_cann_graph": True
        },
    ),
    "CPUExecutionProvider",
]

session = ort.InferenceSession(model_path, sess_options=options, providers=providers)
```
其他编程语言的适配与Python类似，逐步引入到ONNXRuntime中。

### IO Binding

```Python
import numpy as np
import onnxruntime as ort

providers = [
    (
        "CANNExecutionProvider",
        {
            "device_id": 0,
            "arena_extend_strategy": "kNextPowerOfTwo",
            "npu_mem_limit": 2 * 1024 * 1024 * 1024,
            "enable_cann_graph": True,
        },
    ),
    "CPUExecutionProvider",
]

model_path = '<path to model>'

options = ort.SessionOptions()
options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_DISABLE_ALL
options.execution_mode = ort.ExecutionMode.ORT_PARALLEL

session = ort.InferenceSession(model_path, sess_options=options, providers=providers)

x = np.array([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]], dtype=np.int64)
x_ortvalue = ort.OrtValue.ortvalue_from_numpy(x, "cann", 0)

io_binding = sess.io_binding()
io_binding.bind_ortvalue_input(name="input", ortvalue=x_ortvalue)
io_binding.bind_output("output", "cann")

sess.run_with_iobinding(io_binding)

return io_binding.get_outputs()[0].numpy()
```

## 4. 质量、安全与合规
本开源特性需要符合ONNXRuntime社区对其中软件的各种要求，并且也要符合华为主动开源代码的出口标准。

### 4.1 质量与安全

- 软件质量（可服务性）
     1. 代码需遵守ONNXRuntime社区对软件质量的要求，需要经过多人多轮评审方可合入
     2. 新增代码需同步包含测试代码。保证覆盖全部新增点。
     3. 基于社区CI/CD系统，在Linux、Windows、Mac等OS和GPU、GPU等后端上进行功能测试，保证原功能正常。
     4. 代码提交前，需要在内部昇腾设备上进行全量单元测试及功能测试。
     5. 在社区CI/CD系统中增加昇腾场景，保证昇腾功能持续可用。

- 软件安全
     1. 数据安全：软件全程不联网，持久存储中不包含用户敏感信息。
     2. 网络安全：ONNXRuntime通过PCI协议与昇腾硬件通信，不涉及外网出口问题，不涉及分布式内网问题。
     3. 系统安全：基于ONNXRuntime安全机制，定期发布CVE修复或安全补丁。
     4. 应用层安全：不涉及，不提供应用级安全服务，例如密码策略、访问控制等。
     5. 管理安全：本后端提供日志生成和周期性备份机制，方便用户定期审计。

- 可靠性

     本软件面向ONNXRuntime社区的开发行为，不涉及服务上线或者商业生产落地，所有代码公开透明，不涉及私有功能及代码。节点冗余、容灾备份能功能由ONNXRuntime统一支持，本特性不做额外设计和开发。

### 4.2 合规
1. License合规

     ONNXRuntime使用MIT License，本协议是宽松许可证的一种，没有代码开闭源限制，可以随意免费复制、分发、出售，唯一要求是fork项目在源码和二进制文件中保留版权和许可声明。本特性也需遵守ONNXRuntime MIT协议要求，需要在新增源码文件的头部加以注明。

2. 法务合规

     本特性由华为员工在工作中以开源开发的方式负责完成，不涉及商业公司的秘密以及非公开代码，其知识产权属于华为公司，但在贡献给开源社区后，需遵守开源社区对产权等方面的要求。

## 5. 实施计划

|       时间         | 内容 | 状态|
|:-----------------:|:-----------:|:-----------:|
|  2022.06           | 完成方案设计，与社区讨论接入方案，说服社区接收该特性 | Done |
|  2022.07           | 完成框架及核心代码开发，向社区提交PR | Done |
|  2022.10           | 完成框架及核心代码合入，发布正式支持昇腾的新release | Done |
|  2022.12           | 不断优化CANN后端，补齐关键功能 | Done |
|  2023.06           | 推动ONNXRuntime社区支持基于openEuler的昇腾CI，保证昇腾持续可用 | Done |
|  2023.12           | 昇腾后端持续看护，不断优化性能，及时闭环用户提出的问题及新特性需求 | Working in progress |
