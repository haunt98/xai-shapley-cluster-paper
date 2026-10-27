#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, shapes
#import "@preview/lovelace:0.3.1": *

#set text(lang: "vi")
// #set text(font: "Times New Roman") // For submission
#set text(font: "New Computer Modern") // For proof reading
#show math.equation: set text(font: "New Computer Modern Math")
#set text(size: 11pt)

#set page(numbering: "1")
#set math.equation(numbering: "(1)")

#let round_3(v) = {
  let r = calc.round(v, digits: 3)
  if r == 0 { "0" } else { str(r) }
}

// Giá trị Shapley để giải thích độ chính xác của dự đoán

#outline(title: "Mục lục")

#pagebreak()

= Danh mục các từ viết tắt

#table(
  columns: (auto, auto, auto),
  stroke: 0.5pt,
  align: left,
  [*Từ viết tắt*], [*Nghĩa tiếng Anh*], [*Nghĩa tiếng Việt*],

  [AI], [Artificial Intelligence], [Trí tuệ nhân tạo],
  [ML], [Machine Learning], [Học máy],
  [XAI], [Explainable AI], [Trí tuệ nhân tạo giải thích được],
  [MSE], [Mean Squared Error], [Sai số bình phương trung bình],
  [KNN], [K-Nearest Neighbors], [K láng giềng gần nhất],
  [AAKR], [Auto-Associative Kernel Regression], [Hồi quy hạt nhân tự liên kết],
  [TP], [True Positive], [Dương tính thật],
  [FP], [False Positive], [Dương tính giả],
  [TN], [True Negative], [Âm tính thật],
  [FN], [False Negative], [Âm tính giả],
)

#pagebreak()

= Chương 1. MỞ ĐẦU

// MỞ ĐẦU: giới thiệu tóm tắt về công trình nghiên cứu, lý do lựa chọn đề tài, câu hỏi nghiên cứu, mục đích, đối tượng, phạm vi nghiên cứu, phương pháp nghiên cứu, ý nghĩa khoa học hoặc thực tiễn của đề tài;

== 1.1. Giới thiệu tóm tắt về công trình nghiên cứu

Trong thập kỷ qua, AI đã trở thành công nghệ quan trọng trong nhiều ngành công nghiệp, ví dụ như:

- Y tế: Chẩn đoán bệnh theo triệu chứng lâm sàng, phân tích hình ảnh y tế (CT, MRI).
- Tài chính - Ngân hàng: Dự báo biến động thị trường, đánh giá rủi ro tín dụng và phát hiện gian lận giao dịch.
- Thương mại điện tử: Hệ thống gợi ý sản phẩm, phân tích hành vi người tiêu dùng.
- Giao thông: Xe tự động lái, tối ưu hoá lộ trình logistics.
- An ninh: Nhận diện khuôn mặt.

Đa phần các mô hình AI hiệu quả hiện nay đều có kiến trúc rất phức tạp với hàng triệu tham số. Với giá trị đầu vào biết trước khi đưa vào mô hình AI, không dễ gì dự đoán được kết quả đầu ra, việc giải thích tại sao thậm chí còn khó hơn. Vì vậy các mô hình AI này còn được gọi là các hộp đen (black box), chúng ta hoàn toàn không thể biết chính xác bên trong mô hình hoạt động cụ thể như thế nào. Tuy nhiên, bản chất hộp đen này khiến việc đặt niềm tin vào AI trong các hệ thống đòi hỏi tính an toàn cao (safety critical systems) gặp nhiều khó khăn. Các phương pháp XAI ra đời nhằm cố gắng giải thích kết quả đầu ra của mô hình AI, củng cố niềm tin cho người dùng mô hình cũng như giúp cho nhà phát triển mô hình có thể cải thiện được kết quả tốt hơn.

Nghiên cứu này tập trung vào một cách tiếp cận mới trong XAI đó là giải thích *sai số của dự đoán* thay vì giải thích dự đoán. Trong thực tế khi có một vấn đề hay một sự cố xảy ra, ví dụ như sai sót khi mô hình dự đoán sai, thì chúng ta mới sử dụng phương pháp XAI để kiểm tra lại tại sao dự đoán sai lệch so với thực tế. Đối với các phương pháp XAI vốn chỉ tập trung giải thích giá trị dự đoán mà không biết trước kết quả giá trị thực tế, thì kết quả giải thích sẽ chỉ phản ánh được tại sao đưa ra dự đoán chứ không thể giải thích được tại sao lại đưa ra dự đoán lỗi. Nghiên cứu này sẽ trình bày phương pháp XAI sử dụng giá trị thực tế đã được biết, xây dựng dựa trên phương pháp XAI giải thích dự đoán dựa trên mức độ đóng góp của từng cụm dữ liệu huấn luyện (training data cluster) thông qua Lý thuyết trò chơi liên minh Giá trị Shapley (Coalitional Game Theory Shapley values).

== 1.2. Lý do lựa chọn đề tài

Lý do lựa chọn đề tài xuất phát từ 3 nội dung chính sau:

- *Khoảng trống nghiên cứu về phương pháp XAI giải thích cục bộ (local) cho sai số của dự đoán*: Sự phát triển của mô hình AI đi kèm với sự phát triển các phương pháp XAI giải thích cục bộ như LIME @Ribeiro2016, ICE @Goldstein02012015, PredDiff @BLUCHER2022103774. Tuy nhiên điểm chung của các phương pháp này là đều giải thích giá trị dự đoán khi chưa biết trước kết quả thực tế. Bên cạnh đó các phương pháp XAI giải thích cho sai số dự đoán hầu hết đều mang tính toàn cục (global), giải thích trên toàn bộ tập dữ liệu, chứ không giải thích cho từng điểm dữ liệu riêng biệt. Cho nên hiện tại chưa có một phương pháp XAI nào giải thích cục bộ cho sai số dự đoán dựa trên tập dữ liệu mà không phụ thuộc vào mô hình (model agnostic).
- *Tiếp cận hướng dữ liệu:* Nhiều phương pháp XAI tập trung vào đo lường mức độ quan trọng của các đặc trưng (feature) trong dự đoán, nhưng lại bỏ qua tầm quan trọng của tập dữ liệu huấn luyện. Trong thực tế, tập dữ liệu huấn luyện có thể đóng vai trò quyết định đến kết quả dự đoán của mô hình. Nếu tập dữ liệu huấn luyện bị thiên lệch (bias) thì kết quả đầu ra của mô hình cũng sẽ bị thiên lệch theo. Một ví dụ tương tự có thể thấy trong môn bóng rổ: Chiều cao là một đặc trưng rất quan trọng ảnh hưởng đến hiệu suất thi đấu bóng rổ. Tuy nhiên, nếu xét riêng trong giải đấu NBA chuyên nghiệp, nơi mà hầu hết các vận động viên đều đã sở hữu chiều cao vượt trội so với người bình thường, thì chiều cao lại không còn là yếu tố quan trọng có thể giải thích được sự chênh lệch về hiệu suất giữa các cầu thủ nữa. Điều này cho thấy vai trò của một đặc trưng có được coi là *quan trọng* hay không phụ thuộc hoàn toàn vào tập dữ liệu huấn luyện mà mô hình được học. Do đó, việc giải thích mô hình dưới góc nhìn hướng dữ liệu, cụ thể trong nghiên cứu này là đánh giá ảnh hưởng của từng cụm dữ liệu huấn luyện, là cần thiết để hiểu rõ bản chất và cải thiện độ chính xác dự đoán.
- *Nhu cầu thực tiễn trong phân tích sự cố*: Ở các hệ thống đòi hỏi tính an toàn cao, thách thức lớn nhất luôn nằm ở việc liệu các dự đoán của mô hình AI có thực sự chính xác và đáng tin cậy hay không. Câu hỏi tại sao mô hình đưa ra dự đoán như thế này không quan trọng bằng câu hỏi tại sao mô hình lại dự đoán lệch thực tế sau khi có mô hình AI dự báo sai dẫn đến sự cố nghiêm trọng. Hiểu được điều này sẽ giúp các nhà phát triển mô hình sửa chữa, cập nhật mô hình tốt hơn và phòng ngừa các dự đoán sai lệch dẫn đến sự cố trong tương lai.

== 1.3. Câu hỏi nghiên cứu

Nhằm giải quyết khoảng trống nghiên cứu về giải thích sai số dự đoán cục bộ, đề tài tập trung vào việc trả lời các câu hỏi nghiên cứu sau:

- Làm thế nào để ứng dụng Giá trị Shapley từ Lý thuyết trò chơi liên minh nhằm xác định ảnh hưởng cục bộ của các cụm dữ liệu huấn luyện đến sai số dự đoán và độ chính xác phân loại trong bối cảnh giá trị thực tế đã biết?
- Các đặc tính lý thuyết của Giá trị Shapley thể hiện như thế nào trong bài toán giải thích sai số dự đoán cục bộ?
- Việc sử dụng kết quả giải thích có giúp xây dựng chiến lược thu thập dữ liệu huấn luyện mới nhằm cải thiện độ chính xác dự đoán của mô hình hay không?

== 1.4. Mục đích nghiên cứu

*Mục đích tổng quát:* Xây dựng phương pháp XAI mới nhằm giải thích cục bộ cho sai số dự đoán trong bối cảnh giá trị thực tế đã biết, không phụ thuộc vào mô hình, tập trung vào dữ liệu thay vì đặc trưng, để cuối cùng có thể tối ưu hóa cụm dữ liệu huấn luyện cho các mô hình AI.

Để đạt được mục đích trên, đề tài đề ra các mục tiêu cụ thể sau:

- *Về mặt lý thuyết:* Đề xuất phương pháp tính Giá trị Shapley cho các cụm dữ liệu huấn luyện để đánh giá sự đóng góp của từng cụm dữ liệu huấn luyện đến sai số dự đoán cục bộ trong bài toán hồi quy và bài toán phân loại. Đồng thời chứng minh các tính chất của Giá trị Shapley vẫn còn đúng đối với phương pháp này.
- *Về mặt ứng dụng:* Thử nghiệm phương pháp mới trên dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng, từ đó đề xuất chiến lược thu thập dữ liệu huấn luyện để tối thiểu hoá sai số dự đoán của mô hình AI.

Phương pháp này mới là vì chưa có công trình nghiên cứu nào giải thích sai số trong dự đoán cục bộ, và cũng không nhiều công trình tiếp cận theo hướng dữ liệu cụ thể là nghiên cứu tập dữ liệu huấn luyện thay cho hướng nghiên cứu dựa trên đặc trưng vốn đã được nghiên cứu rộng rãi.

== 1.5. Đối tượng và Phạm vi nghiên cứu

Đối tượng nghiên cứu chính: Phương pháp XAI độc lập với mô hình dựa trên Lý thuyết trò chơi liên minh với Giá trị Shapley. Trong đó bao gồm mức độ đóng góp của các cụm dữ liệu huấn luyện đối với sai số dự đoán cục bộ, cụ thể là MSE trong bài toán hồi quy (Regression) và độ chính xác (Accuracy) trong bài toán phân loại (Classification), với bối cảnh là biết trước giá trị thực tế.

Phạm vi nghiên cứu: Nghiên cứu tập trung vào giải thích độ đóng góp của cụm dữ liệu huấn luyện trong bài toán:

- Bài toán hồi quy (Regression) với sai số MSE sử dụng mô hình *Random Forest* và *KNN-10*.
- Phân loại với độ chính xác (accuracy) sử dụng mô hình *AAKR*.

Tập dữ liệu thực nghiệm bao gồm:

- Dữ liệu tạo sinh (synthetic data) để kiểm chứng tính đúng đắn về mặt toán học của phương pháp.
- Dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng tại thành phố @bike_sharing_275.

Giới hạn của nghiên cứu:

- Nghiên cứu không đề xuất cách phân cụm mới cho tập dữ liệu huấn luyện, mà sử dụng các phương pháp phân cụm tự nhiên hoặc có sẵn của dữ liệu
- Nghiên cứu không đề xuất công thức đánh giá sai số dự đoán mới mà sử dụng lại sai số có sẵn như MSE.

== 1.6. Phương pháp nghiên cứu

- *Về mặt lý thuyết*: Nghiên cứu sử dụng Lý thuyết trò chơi liên minh với Giá trị Shapley để định nghĩa mô hình trò chơi cho cụm dữ liệu huấn luyện. Bao gồm các tính chất của Giá trị Shapley, đề xuất và chứng minh các công thức liên quan. Đồng thời giải thích ý nghĩa Giá trị Shapley cho từng cụm dữ liệu huấn luyện trong bối cảnh giải thích sai số dự đoán cục bộ.
- *Về mặt ứng dụng*: Nghiên cứu sử dụng dữ liệu thực nghiệm, để kiểm chứng tính đúng đắn phương pháp, đồng thời đánh giá hiệu quả của phương pháp trong việc giải thích sai số dự đoán cục bộ. Dữ liệu thực nghiệm bao gồm dữ liệu tạo sinh và dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng. Các mô hình được sử dụng bao gồm mô hình *Random Forest*, *KNN* và *AAKR*.

== 1.7. Ý nghĩa khoa học và thực tiễn

- *Ý nghĩa khoa học:* Đề xuất phương pháp XAI mới giải thích sai số dự đoán cục bộ, độc lập với mô hình, tập trung vào dữ liệu thay vì đặc trưng nhờ vào Lý thuyết trò chơi liên minh và Giá trị Shapley. Phương pháp này có thể được áp dụng cho nhiều mô hình AI khác nhau, không bị giới hạn bởi một mô hình cụ thể. Đồng thời nghiên cứu cung cấp một góc nhìn mới về tư duy theo hướng dữ liệu, cụ thể là về cách giải thích đóng góp của từng cụm dữ liệu huấn luyện đối với sai số dự đoán, từ đó giúp các nhà nghiên cứu và phát triển mô hình AI hiểu rõ hơn về cách dữ liệu huấn luyện ảnh hưởng đến kết quả dự đoán.
- *Ý nghĩa thực tiễn:* Phương pháp này có thể giúp các nhà phát triển mô hình AI xác định cụm dữ liệu huấn luyện nào là quan trọng, từ đó tối ưu hóa tập dữ liệu huấn luyện để cải thiện độ chính xác dự đoán của mô hình. Ngoài ra, việc giải thích sai số dự đoán cục bộ sau khi vận hành thực tế hoặc khi có sự cố xảy ra sẽ giúp các nhà phát triển mô hình AI phát hiện và khắc phục các vấn đề trong dữ liệu huấn luyện, từ đó nâng cao độ tin cậy và hiệu quả của các hệ thống AI trong các ứng dụng thực tiễn có tính rủi ro cao.

#pagebreak()

= Chương 2. TỔNG QUAN

// TỔNG QUAN về vấn đề nghiên cứu: phân tích, đánh giá các công trình nghiên cứu liên quan trực tiếp đến đề tài luận văn đã được công bố ở trong và ngoài nước, chỉ ra những vấn đề mà luận văn sẽ tập trung giải quyết, xác định mục tiêu của đề tài, nội dung và phương pháp nghiên cứu;

== 2.1. Các công trình nghiên cứu liên quan

XAI được sinh ra để cung cấp cho người dùng và nhà phát triển các công cụ để hiểu rõ hơn về cách mà mô hình AI đưa ra dự đoán. Ví dụ như một mô hình AI quyết định cho vay tín dụng thì kết quả chỉ có thể là quyết định cho vay hoặc không, nhưng khi khách hàng hỏi lại kỹ hơn tại sao lại từ chối yêu cầu vay vốn thì lúc đó cần phải giải thích rõ hơn ví dụ như khách hàng có lịch sử tín dụng xấu, hoặc vì một tiêu chuẩn nào đó khác. XAI còn được dùng để kiểm chứng mô hình có học được đúng các đặc trưng như nhà phát triển mong muốn hay không. Ví dụ với một mô hình AI phân loại loài gấu, giữa gấu bắc cực và gấu nâu, có khả năng mô hình học đặc trưng màu sắc của tuyết để phân biệt thay vì học đặc trưng về màu sắc hay hình dáng cơ thể của 2 loài gấu.

#figure(
  table(
    columns: (auto, auto, auto),
    stroke: 0.5pt,
    align: left,
    [*Toàn cục hay cục bộ*], [*Hướng đặc trưng hay dữ liệu*], [*Phương pháp*],

    table.cell(rowspan: 2)[*Toàn cục*],
    [Đặc trưng],
    [SAGE @NEURIPS2020_c7bf0b7c \
      Permutation feature importance @fisher2019modelswrongusefullearning \
      ALEPlots @Apley2020
    ],

    [Dữ liệu],
    [Data Banzhaf @wang2023databanzhafrobustdata \
      Cook’s distance @Cook01031979
    ],

    table.cell(rowspan: 2)[*Cục bộ*],
    [Đặc trưng],
    [Marginal Shapley values @lundberg2017unifiedapproachinterpretingmodel \
      Conditional Shapley values @aas2020explainingindividualpredictionsfeatures \
      PredDiff @BLUCHER2022103774 \
      Anchors @Ribeiro2018 \
      Counterfactual explanations @wachter2018counterfactualexplanationsopeningblack \
      LIME @Ribeiro2016 \
      ICE @Goldstein02012015
    ],

    [Dữ liệu],
    [Influence functions for perturbing training data @pmlr-v70-koh17a \
      Case-based explanations @Nugent2009 \
      Shapley values for cluster importance @Brandsaeter2022
    ],
  ),
  caption: [Phân loại các phương pháp XAI theo phạm vi và đối tượng giải thích],
  placement: none,
) <table-overview>

@table-overview tổng hợp các phương pháp XAI được phân loại theo 2 tiêu chí: phạm vi giải thích (toàn cục hay cục bộ) và đối tượng giải thích (đặc trưng hay dữ liệu huấn luyện). Một số phương pháp XAI cung cấp giải thích toàn cục, nghĩa là giải thích toàn bộ mô hình AI, từng thành phần của mô hình đóng góp đến toàn bộ dự đoán như thế nào. Trong khi các phương pháp khác cung cấp giải thích cục bộ, nghĩa là giải thích từng dự đoán riêng lẻ của mô hình tại từng thời điểm cụ thể. Một khác biệt quan trọng nữa giữa các phương pháp XAI là giải thích dựa trên đặc trưng hay là dữ liệu huấn luyện. Các phương pháp XAI toàn cục có thể chia làm 2 nhóm là phân tích ảnh hưởng của các đặc trưng khác nhau ví dụ như: *SAGE* @NEURIPS2020_c7bf0b7c, *Permutation feature importance* @fisher2019modelswrongusefullearning và *ALEPlots* @Apley2020 hoặc đánh giá sử dụng dữ liệu huấn luyện ví dụ như: *Data Banzhaf* @wang2023databanzhafrobustdata.

Bên cạnh hướng giải thích toàn cục là hướng cục bộ, để giải thích từng dự đoán đơn lẻ tại từng thời điểm cục bộ, chúng ta cũng có thể chia thành 2 nhóm phương pháp XAI dựa trên mức độ quan trọng của đặc trưng hoặc dựa trên mức độ ảnh hưởng của cụm dữ liệu huấn luyện đến dự đoán. Nhóm thứ 1 có thể kể đến như Marginal Shapley values @lundberg2017unifiedapproachinterpretingmodel, Conditional Shapley values @aas2020explainingindividualpredictionsfeatures, PredDiff @BLUCHER2022103774, Anchors @Ribeiro2018, Counterfactual explanations @wachter2018counterfactualexplanationsopeningblack, LIME @Ribeiro2016 và ICE @Goldstein02012015. Nhóm thứ 2 có thể kể đến như Influence functions for perturbing training data @pmlr-v70-koh17a, Case-based explanations @Nugent2009 và Shapley values for cluster importance @Brandsaeter2022. Nhóm thứ 1 chứa các phương pháp XAI phổ biến và được trích dẫn nhiều nhất trong các công trình nghiên cứu khác. Nhóm thứ 2, tập trung vào dữ liệu, thì lại ít phương pháp hơn. Có 3 phương pháp có thể kể đến là:

- *Influence functions for perturbing training data* @pmlr-v70-koh17a để khảo sát mức độ nhạy cảm của dự đoán đối với các nhiễu loạn nhỏ trong tập dữ liệu huấn luyện.
- *Case-based explanations* @Nugent2009 mục đích là để dùng các ví dụ dự đoán trong quá khứ để kiểm tra và giải thích cho các ví dụ trong tương lai.
- *Shapley values for cluster importance* @Brandsaeter2022 là một cách tiếp cận đánh giá mức độ ảnh hưởng của từng cụm dữ liệu huấn luyện nhỏ trong tập dữ liệu huấn luyện đến dự đoán của mô hình AI.

Nghiên cứu này sẽ dựa trên phương pháp *Shapley values for cluster importance* @Brandsaeter2022 làm nền tảng để phát triển thành phương pháp XAI mới giải thích sai số dự đoán cục bộ, độc lập với mô hình, tập trung vào dữ liệu thay vì đặc trưng.

== 2.2. Giá trị Shapley trong Trò chơi liên minh

Giá trị Shapley @Shapley1953 được sử dụng trong lĩnh vực Lý thuyết trò chơi liên minh để giải quyết bài toán chia lợi ích công bằng giữa các người chơi trong một trò chơi liên minh. Giả sử có một trò chơi với liên minh $N$ người chơi. Sau khi chơi xong, liên minh sẽ được nhận phần thưởng là $v(N)$. Lấy ví dụ trò chơi câu cá, người chơi là những người đi câu cá, và phần thưởng là số cá câu được.

Bài toán đặt ra là làm thế nào để chia phần thưởng công bằng cho từng người chơi. Nếu toàn bộ người chơi cùng tham gia thì tổng phần thưởng là $v(N)$, nếu mỗi lần chơi chỉ có một tập con $S subset N$ người chơi tham gia, thì phần thưởng nhận được là $v(S)$. Chúng ta định nghĩa hàm tính phần thưởng $v$ là một ánh xạ từ liên minh $S$ và ra phần thưởng là số thực $v : 2^(|N|) arrow.r RR$. Một người chơi $i$, có thể tham gia nhiều liên minh $S$ khác nhau. Dựa vào đóng góp của người chơi trong toàn bộ các liên minh mà tính ra được phần thưởng mà người chơi xứng đáng được nhận.

Có nhiều cách để tính phần thưởng cho người chơi, trong nội dung nghiên cứu này sẽ sử dụng Giá trị Shapley, công thức được tham khảo từ @Brandsaeter2022 như sau:

#figure(
  $
    phi_i = sum_(S subset.eq N backslash {i}) (|S|!(|N| - |S| - 1)!) / (|N|!) dot [v(S union {i}) - v(S)]
  $,
) <math-shapley-value-1>

@math-shapley-value-1 chính là giá trị trung bình toàn bộ phần chênh lệch giữa phần thưởng tất cả các liên minh có người chơi $i$ tham gia $S union {i}$ và phần thưởng tất cả các liên minh còn lại không có người chơi $i$. Với trò chơi câu cá, chúng ta so sánh toàn bộ số cá câu được khi có người chơi $i$ tham gia và không có người chơi $i$ tham gia trong toàn bộ liên minh có thể lập ra để tính ra phần thưởng của người chơi.

Từ công thức @math-shapley-value-1, có thể hiểu Giá trị Shapley của người chơi $i$ là trung bình giá trị đóng góp (marginal contribution) theo hoán vị tương ứng của các liên minh. Do đó có thể viết lại công thức Giá trị Shapley tương đương @Brandsaeter2022 như sau:

#figure(
  $
    phi_i = 1 / (|N|!) sum_(cal(O) in pi(|N|)) [v("Pre"^i (cal(O)) union {i}) - v("Pre"^i (cal(O)))]
  $,
) <math-shapley-value-2>

Trong đó:

- $pi(|N|)$ là tập hợp tất cả các hoán vị của $N$ người chơi.
- $"Pre"^i (cal(O))$ là tập hợp tất cả người chơi có vị trí ở trước người chơi $i$ khi sắp xếp trong hoán vị $cal(O) in pi(|N|)$.

Giá trị Shapley @Shapley1953 có 4 tính chất cơ bản sau:

- Tính *hiệu quả* (Efficiency): Toàn bộ phần thưởng đều được chia hết cho từng người chơi (sau khi chia xong thì không còn phần thưởng nào).

#figure(
  $
    sum_(i in N) phi_i = v(N)
  $,
) <math-shapley-value-efficiency>

- Tính *đối xứng* (Symmetry): Nếu chúng ta có

#figure(
  $
    v(S union {i}) = v(S union {j})
  $,
) <math-shapley-value-symmetry>

mà mọi liên minh $S subset.eq N$ đều không chứa $i$ và $j$, thì phần thưởng của 2 người chơi này phải bằng nhau $phi_i = phi_j$.


- Tính *tuyến tính* (Linearity): Nếu chúng ta có 2 trò chơi với 2 hàm phần thưởng khác nhau $v$ và $w$, thì phần thưởng của người chơi trong trò chơi tổng hợp sẽ bằng tổng phần thưởng của người chơi trong từng trò chơi riêng lẻ.

#figure(
  $
    phi_i(v + w) = phi_i(v) + phi_i(w)
  $,
) <math-shapley-value-linearity-1>

cho mọi $i in N$. Bên cạnh đó, với mọi số thực $a$, chúng ta cũng có

#figure(
  $
    phi_i(a v) = a phi_i(v)
  $,
) <math-shapley-value-linearity-2>

cho mọi $i in N$.

- *Người chơi rỗng* (Null player): Người chơi rỗng là người chơi có đóng góp bằng 0, $phi_i = 0$, nghĩa là $v({i}) = v(emptyset)$ và $v(S union {i}) = v(S)$ cho toàn bộ liên minh $S subset.eq N$. Thông thường chúng ta ngầm hiểu rằng $v(emptyset) = 0$.

Quay lại ví dụ về trò chơi câu cá, giả sử có 3 người chơi $A$, $B$, $C$. @demo-fish-1 thể hiện phần thưởng cho toàn bộ liên minh có thể xảy ra. Có thể thấy nếu cả 3 người chơi đều tham gia thì phần thưởng là lớn nhất. Bên cạnh đó người chơi $B$ và người chơi $C$ đều có đóng góp như nhau vì $v({A, B}) = v({A, C})$, nên theo tính đối xứng thì Giá trị Shapley của $B$ và $C$ là giống nhau.


#figure(
  table(
    columns: (auto, auto),
    align: (left, right),

    [*Liên minh*], [*Số cá câu được*],

    [$A, B, C$], [100],
    [$A, B$], [70],
    [$A, C$], [70],
    [$B, C$], [20],
    [$A$], [30],
    [$B$], [20],
    [$C$], [20],
    [$emptyset$], [0],
  ),
  caption: [
    Phần thưởng (số lượng cá) cho từng liên minh của người chơi câu cá.
  ],
)<demo-fish-1>

Để tính Giá trị Shapley, chúng ta cần tính toàn bộ phần chênh lệch đóng góp theo toàn bộ hoán vị có thể có cho từng người chơi. @demo-fish-2 tính cho người chơi $A$, @demo-fish-3 tính cho người chơi $B$ và người chơi $C$ vì $B$ và $C$ có Giá trị Shapley giống nhau.


#figure(
  table(
    columns: 6,
    align: (left, left, left, right, right, right),

    [*$cal(O)$*], [*$S union {i}$*], [*$S$*], [*$v(S union {i})$*], [*$v(S)$*], [*$v(S union {i}) - v(S)$*],

    [$(A, B, C)$], [${A}$], [$emptyset$], [30], [0], [30],
    [$(A, C, B)$], [${A}$], [$emptyset$], [30], [0], [30],
    [$(B, A, C)$], [${A, B}$], [${B}$], [70], [20], [50],
    [$(B, C, A)$], [${A, B, C}$], [${B, C}$], [100], [20], [80],
    [$(C, A, B)$], [${A, C}$], [${C}$], [70], [20], [50],
    [$(C, B, A)$], [${A, B, C}$], [${B, C}$], [100], [20], [80],
  ),
  caption: [
    Bảng phục vụ tính Giá trị Shapley cho người chơi $A$
  ],
) <demo-fish-2>

#figure(
  table(
    columns: 6,
    align: (left, left, left, right, right, right),

    [*$cal(O)$*], [*$S union {i}$*], [*$S$*], [*$v(S union {i})$*], [*$v(S)$*], [*$v(S union {i}) - v(S)$*],

    [$(A, B, C)$], [${A, B}$], [${A}$], [70], [30], [40],
    [$(A, C, B)$], [${A, B, C}$], [${A, C}$], [100], [70], [30],
    [$(B, A, C)$], [${B}$], [$emptyset$], [20], [0], [20],
    [$(B, C, A)$], [${B}$], [$emptyset$], [20], [0], [20],
    [$(C, A, B)$], [${A, B, C}$], [${A, C}$], [100], [70], [30],
    [$(C, B, A)$], [${B, C}$], [${C}$], [20], [20], [0],
  ),
  caption: [
    Bảng phục vụ tính Giá trị Shapley cho người chơi $B$
  ],
) <demo-fish-3>

Cuối cùng, Giá trị Shapley của từng người chơi chính là trung bình của toàn bộ phần chênh lệch đóng góp của toàn bộ hoán vị.

$
  phi_A = (30 + 30 + 50 + 80 + 50 + 80) / 6 approx 53.3
$

$
  phi_B = phi_C = (40 + 30 + 20 + 20 + 30 + 0)/6 approx 23.3
$

Kiểm tra lại tính hiệu quả $phi_A + phi_B + phi_C = 100$ đúng với @demo-fish-1.

== 2.3. Giá trị Shapley đối với sự quan trọng của đặc trưng

Nếu thay đổi trò chơi thành bài toán hồi quy, cụ thể là dự đoán kết quả từ các đặc trưng, chúng ta vẫn có thể áp dụng Giá trị Shapley để giải thích. Xét một bài toán máy học tiêu chuẩn: có tập huấn luyện $cal(D)^("train")$ với $J$ đặc trưng $x_1, ..., x_J$ và giá trị $y$ là kết quả cần dự đoán, dùng để huấn luyện mô hình $f : cal(A) arrow.r RR$ với $cal(A) = cal(A)_1 times cal(A)_2 times ... times cal(A)_J$. Các đặc trưng đóng vai như người chơi trong trò chơi dự đoán kết quả này, mục đích là để tìm mức độ đóng góp của từng đặc trưng ảnh hưởng đến kết quả dự đoán tại một điểm dữ liệu cụ thể $x$.

Công thức tính phần thưởng cũng như là mức độ đóng góp của đặc trưng được định nghĩa như sau:

$
  v(S)(x) = sum_(z in cal(A)) p(z)(f(tau(x, z, S)) - f(z))
$ <math-shapley-value-feature-reward>

với $tau(x, z, S) = (u_1, ..., u_J)$ với điều kiện $u_j = x_j$ nếu $j in S$ và $u_j = z_j$ nếu $j in.not S$. $z$ là điểm dữ liệu ngẫu nhiên (random data points) vẫn lấy từ không gian $cal(A)$, $p(z)$ là phân phối của các điểm dữ liệu ngẫu nhiên $z$ trong không gian $cal(A)$.

Do đó công thức tính Giá trị Shapley cho đặc trưng $j$ là:

$
  phi_j(x) = frac(1, J!) sum_(cal(O) in pi(J)) sum_(z in cal(A)) p(z) [f(tau(x, z, "Pre"^j (cal(O)) union {j})) - f(tau(x, z, "Pre"^j (cal(O))))]
$ <math-shapley-value-feature-1>

với $pi(J)$ là tập hợp tất cả các hoán vị của tập $J$ đặc trưng, $"Pre"^j (cal(O))$ là tập hợp tất cả các đặc trưng có vị trí ở trước đặc trưng $j$ khi sắp xếp trong hoán vị $cal(O) in pi(J)$. Và vì $f(z)$ đều xuất hiện trong công thức $v("Pre"^j (cal(O)) union {j})$ và $v("Pre"^j (cal(O)))$, nên chúng bị triệt tiêu, không xuất hiện trong @math-shapley-value-feature-1. Để đơn giản chúng ta giả sử tập $cal(A)$ là rời rạc.

Tuy nhiên thông thường chúng ta không biết được phân phối $p(z)$, và số các liên minh của $N$ đặc trưng là $2^(|N|)$ khi số đặc trưng tăng lên thì số các liên minh cũng tăng lên rất nhanh, nên việc tính chính xác $v(S)$ gần như là không thể. Để đơn giản hơn, chúng ta có thể sử dụng phân phối mẫu ngẫu nhiên (random sampling) và thuật toán xấp xỉ @aas2020explainingindividualpredictionsfeatures @lundberg2017unifiedapproachinterpretingmodel @Strumbelj2010 @Strumbelj2011 để viết lại Giá trị Shapley xấp xỉ như sau:

$
  hat(phi)_j (x) = 1/M sum_(m=1)^M [f(tau(x, z^m, "Pre"^j (cal(O)^m) union {j})) - f(tau(x, z^m, "Pre"^j (cal(O)^m)))]
$ <math-shapley-value-feature-2>

@math-shapley-value-feature-2 thay vì tìm toàn bộ hoán vị của toàn bộ liên minh, thay vào đó chỉ lấy $M$ mẫu ngẫu nhiên. Với từng mẫu ngẫu nhiên $m$, chúng ta có được hoán vị $cal(O) in pi(J)$ và điểm dữ liệu $z^m in cal(A)$ theo phân phối $p$. Vì $p$ thường là không biết trước nên khi tính toán chúng ta lấy mẫu theo tập dữ liệu @Strumbelj2010.

== 2.4. Giá trị Shapley đối với sự quan trọng của cụm dữ liệu

Dựa trên Giá trị Shapley đối với sự quan trọng của đặc trưng, @Brandsaeter2022 đề xuất phương pháp XAI mới để giải thích mức độ quan trọng của từng cụm dữ liệu trong tập dữ liệu huấn luyện thay vì đặc trưng trong dự đoán. Trò chơi và phần thưởng vẫn được định nghĩa tương tự, chúng ta thay đổi định nghĩa người chơi trở thành các tập con trong tập dữ liệu huấn luyện, để nhằm giải thích dự đoán bị ảnh hưởng bởi các cụm dữ liệu huấn luyện như thế nào.

Như ở chương trước, chúng ta vẫn sẽ sử dụng hàm hồi quy để minh hoạ $f : cal(A) arrow.r RR$ với $cal(A) = cal(A)_1 times cal(A)_2 times ... times cal(A)_J$. Tập dữ liệu huấn luyện được chia thành $K$ cụm dữ liệu $cal(Q)_k$ không giao nhau, sao cho $cal(Q)_1 union ... union cal(Q)_K$ chính là toàn bộ tập dữ liệu huấn luyện $cal(D)^("train")$. Cách chia cụm dữ liệu huấn luyện ảnh hưởng trực tiếp đến việc giải thích dự đoán. Ví dụ có thể chia thành các cụm theo thời gian, cụ thể là 12 tháng trong năm. Hoặc lấy riêng từng điểm dữ liệu làm từng cụm cụ thể, lúc này thay vì trả lời cho câu hỏi cụm dữ liệu nào ảnh hưởng đến kết quả dự đoán thì sẽ trả lời cho câu hỏi điểm dữ liệu cụ thể nào ảnh hưởng đến kết quả dự đoán nhất.

Trở lại với trò chơi liên minh, các cụm $cal(Q)_k$ là người chơi và hàm phần thưởng được định nghĩa như sau:

$
  v(S)(x) = f_S (x)
$ <math-shapley-value-cluster-reward>

trong đó $f_S (x)$ là hàm dự đoán được huấn luyện từ hợp của các $cal(Q)_k$ với $k in S subset.eq N$.

Giá trị Shapley cho cụm dữ liệu $k$ được định nghĩa như sau:

$
  phi_k(x) = frac(1, K!) sum_(cal(O) in pi(K)) (f_("Pre"^k (cal(O)) union {k})(x) - f_("Pre"^k (cal(O)))(x))
$ <math-shapley-value-cluster-1>

trong đó $pi(K)$ là tập hợp tất cả các hoán vị của tập $K$ cụm dữ liệu, $"Pre"^k (cal(O))$ là tập hợp tất cả các cụm dữ liệu có vị trí ở trước cụm dữ liệu $k$ khi sắp xếp trong hoán vị $cal(O) in pi(K)$.

Áp dụng cách xấp xỉ tương tự như @math-shapley-value-feature-2, chúng ta có thể viết lại công thức Giá trị Shapley cho cụm dữ liệu $k$ một cách xấp xỉ như sau:

$
  hat(phi)_k (x) = 1/M sum_(m=1)^M (f_("Pre"^k (cal(O)^m) union {k})(x) - f_("Pre"^k (cal(O)^m))(x))
$

Với từng mẫu ngẫu nhiên $m$, chúng ta có được hoán vị $cal(O) in pi(K)$ lấy ngẫu nhiên theo phân phối đều (uniform).

Đối với trường hợp chúng ta không có dữ liệu, tương đương với $S = emptyset$, chúng ta định nghĩa dự đoán bằng $0$, tương đương với $f_emptyset (x) = 0$ với mọi $x in cal(A)$. Điều này tương đương với tính chất người chơi rỗng trong Giá trị Shapley $v(emptyset) = 0$, nghĩa là nếu không có dữ liệu huấn luyện thì dự đoán sẽ bằng 0.

#pagebreak()

= Chương 3. PHƯƠNG PHÁP NGHIÊN CỨU

// PHƯƠNG PHÁP NGHIÊN CỨU: cơ sở lý thuyết, lý luận, cách tiếp cận vấn đề nghiên cứu;

Nghiên cứu này sử dụng cách tiếp cận Giá trị Shapley đối với sự quan trọng của cụm dữ liệu, nhưng thay vì giải thích dự đoán, nghiên cứu này sẽ giải thích sai số dự đoán. Đối với bài toán hồi quy, chỉ số đánh giá cho sai số dự đoán thường là sai số tuyệt đối (absolute error) hoặc sai số bình phương (squared error). @math-shapley-value-feature-reward và @math-shapley-value-cluster-reward đều có thể chỉnh sửa để sử dụng các loại chỉ số này để đánh giá. Nghiên cứu này chọn sai số bình phương để đánh giá sai số dự đoán.


== 3.1. Giải thích cục bộ

Chúng ta tiếp tục sử dụng hàm hồi quy $f : cal(A) arrow.r RR$. Tập dữ liệu huấn luyện được chia thành $K$ cụm dữ liệu $cal(Q)_k$ không giao nhau, sao cho $cal(Q)_1 union ... union cal(Q)_K$ chính là toàn bộ tập dữ liệu huấn luyện $cal(D)^("train")$. Lúc này chúng ta sửa hàm phần thưởng $v$ trong @math-shapley-value-cluster-reward cho người chơi $Q_k$ như sau:

$
  v(S)(x) = (y - f_S (x))^2
$ <math-shapley-value-hindsight-reward-1>

trong đó $f_S$ là hàm dự đoán được huấn luyện từ hợp của các $cal(Q)_k$ với $k in S subset.eq N$. Hàm phần thưởng này dùng để tính sai số bình phương của dự đoán $f_S (x)$ so với giá trị thực tế $y$. Tương tự như @math-shapley-value-cluster-1, Giá trị Shapley cho cụm dữ liệu $k$ được định nghĩa như sau:

$
  phi_k (x) = frac(1, K!) sum_(cal(O) in pi(K)) [(y - f_("Pre"^k (cal(O)) union {k})(x))^2 - (y - f_("Pre"^k (cal(O)))(x))^2]
$ <math-shapley-value-hindsight-1>

trong đó $pi(K)$ là tập tất cả các hoán vị của $K$ cụm dữ liệu, $"Pre"^k (cal(O))$ là tập hợp tất cả các cụm dữ liệu có vị trí ở trước cụm dữ liệu $k$ khi sắp xếp trong hoán vị $cal(O) in pi(K)$.

#figure(
  diagram(
    spacing: (10mm, 6mm),
    node-stroke: 1pt,
    edge-stroke: 0.8pt,

    // Q_1, Q_2, ..., Q_K
    node(
      (1.0, 0),
      text(fill: white)[$Q_1$],
      shape: "circle",
      fill: blue.darken(30%),
      stroke: black + 1pt,
      width: 10mm,
      height: 10mm,
      name: <q1>,
    ),
    node(
      (2.0, 0),
      text(fill: white)[$Q_2$],
      shape: "circle",
      fill: blue.darken(30%),
      stroke: black + 1pt,
      width: 10mm,
      height: 10mm,
      name: <q2>,
    ),
    node((2.5, 0), $[dots]$, stroke: none, name: <q-dots>),
    node(
      (3.5, 0),
      text(fill: white)[$Q_K$],
      shape: "circle",
      fill: blue.darken(30%),
      stroke: black + 1pt,
      width: 10mm,
      height: 10mm,
      name: <qk>,
    ),

    // D_train
    node(
      (2.5, 1.5),
      $cal(D)^"train"$,
      shape: shapes.ellipse,
      stroke: black + 1pt,
      width: 20mm,
      height: 15mm,
      name: <dtrain>,
    ),

    // D_test
    node(
      (4.0, 2.5),
      align(center)[$cal(D)^"test"$\ #v(0.5mm) $x$ \& $y$],
      shape: shapes.ellipse,
      stroke: black + 1pt,
      width: 20mm,
      height: 15mm,
      name: <dtest>,
    ),

    // Black box
    node(
      (2.5, 3.5),
      [Hộp đen],
      shape: "rect",
      fill: luma(80%),
      stroke: black + 1.2pt,
      corner-radius: 4pt,
      width: 30mm,
      height: 15mm,
      name: <bbox>,
    ),

    // Loss formula
    node(
      (2.5, 5.0),
      $(f(x) - y)^2$,
      stroke: none,
      name: <loss>,
    ),

    node(
      (2.5, 6.5),
      align(center)[
        #v(2mm)
        Hàm phần thưởng $v$
        #v(3mm)
        #text(fill: green.darken(20%), weight: "bold")[
          TRÒ CHƠI\ LIÊN MINH
        ]
        #v(3mm)
        K người chơi
        #v(2mm)
      ],
      shape: "rect",
      stroke: green.darken(20%) + 1.2pt,
      corner-radius: 12pt,
      width: 45mm,
      name: <cgame>,
    ),

    node(
      (2.5, 8.5),
      align(center)[
        Giá trị Shapley\
        $phi_1 (x), phi_2 (x), ..., phi_K (x)$
      ],
      stroke: none,
      name: <shapley>,
    ),

    edge(<dtrain>, <q1>, "->", stroke: (dash: "dashed")),
    edge(<dtrain>, <q2>, "->", stroke: (dash: "dashed")),
    edge(<dtrain>, <q-dots>, "->", stroke: (dash: "dashed")),
    edge(<dtrain>, <qk>, "->", stroke: (dash: "dashed")),

    edge(<dtrain>, <bbox>, "->", stroke: (dash: "dashed")),

    edge(<dtest>, <bbox>, "->", label: [$x$], corner: right, stroke: (
      dash: "dashed",
    )),
    edge(<dtest>, <loss>, "->", label: [$y$], corner: right, stroke: (
      dash: "dashed",
    )),
    edge(<bbox>, <loss>, "->", label: [$f(x)$], stroke: (dash: "dashed")),

    edge(<q1>, <cgame>, "->", label: [người chơi], corner: left, stroke: (
      dash: "dashed",
    )),
    edge(<cgame>, <shapley>, "->", stroke: (dash: "dashed")),
  ),
  caption: [Minh hoạ ý tưởng giải thích cục bộ],
) <diagram-idea-individual>

@diagram-idea-individual minh hoạ cách giải thích cục bộ cho từng dự đoán riêng lẻ tại từng thời điểm cụ thể. Từ đó, chúng ta có thể xác định được cụm dữ liệu huấn luyện nào đóng góp nhiều nhất vào sai số dự đoán tại điểm dữ liệu $x$.

Có một vấn đề là tính chất *Người chơi rỗng* không còn đúng nữa vì với $f_emptyset (x) = 0$ thì $v(emptyset) = (y - 0)^2 = y^2$ chứ không phải bằng 0 theo @math-shapley-value-hindsight-reward-1.

Để giải quyết vấn đề này, chúng ta có thể định nghĩa lại hàm phần thưởng $v$ như sau:

$
  v(S)(x) = (y - f_S (x))^2 - y^2
$ <math-shapley-value-hindsight-reward-2>

khi đó nếu $f_S (x) = 0$ thì $v(S)(x) = (y - 0)^2 - y^2 = 0$ đúng với tính chất *Người chơi rỗng*. Và vì $y^2$ là cố định trong cả 2 hàm phần thưởng $v("Pre"^k (cal(O)) union {k})$ và $v("Pre"^k (cal(O)))$, nên chúng bị triệt tiêu trong @math-shapley-value-hindsight-1. Do đó Giá trị Shapley của 2 hàm phần thưởng @math-shapley-value-hindsight-reward-1 và @math-shapley-value-hindsight-reward-2 là giống nhau.

Áp dụng cách xấp xỉ tương tự như @math-shapley-value-feature-2, chúng ta có thể viết lại công thức Giá trị Shapley cho cụm dữ liệu $k$ một cách xấp xỉ như sau:

$
  hat(phi)_k (x) = 1/M sum_(m=1)^M [(y - f_("Pre"^k (cal(O)^m) union {k})(x))^2 - (y - f_("Pre"^k (cal(O)^m))(x))^2]
$ <math-shapley-value-hindsight-local>

Với từng mẫu ngẫu nhiên $m$, chúng ta có được hoán vị $cal(O) in pi(K)$ lấy ngẫu nhiên theo phân phối đều (uniform).

Thuật toán để tính xấp xỉ Giá trị Shapley cục bộ cho từng cụm dữ liệu $k$ tại điểm dữ liệu $x$ được trình bày như sau:

#figure(
  pseudocode-list(
    booktabs: true,
    line-numbering: none,
  )[
    - *Khởi tạo:*
    - Số lần lặp $M$;
    - Chia dữ liệu huấn luyện thành các cụm: $Q_1, Q_2, ..., Q_K$;
    - $phi_k (x) := 0$;
    + *for* $m = 1, ..., M$ *do*
      + Lấy mẫu một hoán vị ngẫu nhiên $cal(O) in pi(K)$;
      + Tạo tập dữ liệu $cal(D)^+$ gồm $Q_k$ và các $Q_i$ với $i$ đứng trước $k$ trong $cal(O)$;
      + Dùng tập dữ liệu $cal(D)^+$ để huấn luyện một hàm $f_(cal(D)^+)$;
      + Tạo tập dữ liệu $cal(D)^-$ gồm các $Q_i$ với $i$ đứng trước $k$ trong $cal(O)$;
      + Dùng tập dữ liệu $cal(D)^-$ để huấn luyện một hàm $f_(cal(D)^-)$;
      + Cập nhật Giá trị Shapley: \
        $phi_k (x) := phi_k (x) + (y - f_(cal(D)^+)(x))^2 - (y - f_(cal(D)^-)(x))^2$
    + *end*
    + $phi_k (x) := frac(phi_k (x), M)$;
  ],
  kind: "algorithm",
  caption: [Xấp xỉ Giá trị Shapley cục bộ cho cụm dữ liệu $k$ tại điểm dữ liệu $x$ với trò chơi sai số bình phương],
  supplement: [Thuật toán],
) <algorithm-shapley-value-hindsight>

== 3.2. Giải thích toàn cục

Nếu như mục *3.1* giải thích cục bộ cho từng dự đoán riêng lẻ tại từng thời điểm cụ thể, chúng ta có thể định nghĩa lại hàm phần thưởng cho việc đánh giá hiệu quả toàn cục (global performance), đó là hiệu quả của toàn bộ tập dữ liệu kiểm thử $cal(D)^"test"$ thay vì từng dự đoán riêng lẻ. Ví dụ chúng ta định nghĩa hàm phần thưởng $v$ sử dụng MSE như sau:

$
  macron(v)(S) = 1/T sum_(t=1)^T (y_t - f_S (x_t))^2
$ <math-shapley-value-hindsight-reward-3>

trong đó $T$ là số điểm dữ liệu trong tập kiểm thử $cal(D)^"test"$.

*Mệnh đề 1.* Giá trị Shapley toàn cục đối với trò chơi sử dụng MSE @math-shapley-value-hindsight-reward-3 bằng trung bình cộng của toàn bộ Giá trị Shapley cục bộ sử dụng sai số bình phương @math-shapley-value-hindsight-reward-1.

*Chứng minh.* Giá trị Shapley toàn cục $macron(phi)_k$ của cụm dữ liệu $k$ được định nghĩa như sau:

$
  macron(phi)_k = 1/(K!) sum_(cal(O) in pi(K)) [ 1/T sum_(t=1)^T (y_t - f_("Pre"^k (cal(O)) union {k}) (x_t))^2 - 1/T sum_(t=1)^T (y_t - f_("Pre"^k (cal(O))) (x_t))^2 ] \
  = 1/T sum_(t=1)^T 1/(K!) sum_(cal(O) in pi(K)) [ (y_t - f_("Pre"^k (cal(O)) union {k}) (x_t))^2 - (y_t - f_("Pre"^k (cal(O))) (x_t))^2 ] \
  = 1/T sum_(t=1)^T phi_k (x_t).
$ <math-shapley-value-hindsight-global>

== 3.3. Bài toán phân loại

Ở các mục trước, chúng ta đã xem xét các hàm hồi quy $f : cal(A) arrow.r RR$ để sử dụng Giá trị Shapley. Chúng ta cũng có thể áp dụng phương pháp tương tự cho các bài toán *phân loại*, xét một hàm phân loại $g : cal(A) arrow.r cal(B)$, với $cal(A)$ là không gian đặc trưng, và $cal(B)$ là không gian các lớp được phân loại. Khi chúng ta biết chính xác phân loại lớp thực tế $c$, chúng ta có thể so sánh ngược lại với các lớp được dự đoán $g(x)$ và tính được độ đo hiệu suất khác nhau để đánh giá.

Lấy ví dụ bài toán phát hiện lỗi trong hệ thống máy móc. Dựa trên dữ liệu từ một tập hợp gồm $J$ cảm biến đang theo dõi thiết bị, $cal(A)_1 times dots.c times cal(A)_J$, hàm $g$ sẽ dự đoán xem thiết bị đang có lỗi hay không. Trong ví dụ này, $cal(B)$ chỉ bao gồm 2 lớp: lớp bình thường và lớp bị lỗi.

Khi so sánh các giá trị dự đoán và giá trị thực tế trên toàn bộ tập dữ liệu kiểm thử (cho tất cả các bước thời gian $t = 1, dots, T$), chúng ta đếm số lượng TP (dự đoán có lỗi, thực tế có lỗi), FP (dự đoán có lỗi, thực tế bình thường), FN (dự đoán bình thường, thực tế có lỗi), và TN (dự đoán bình thường, thực tế bình thường). Dựa trên các giá trị này, chúng ta có thể tính toán các độ đo hiệu suất khác nhau, ví dụ như *độ nhạy* (sensitivity) thể hiện tỷ lệ dương tính thật:

$
  frac("TP", "TP" + "FN")
$ <math-sensitivity>

*độ đặc hiệu* (specificity) thể hiện tỷ lệ âm tính thật:

$
  frac("TN", "TN" + "FP")
$ <math-specificity>

và *độ chính xác* (accuracy) thể hiện tỷ lệ dự đoán đúng:

$
  frac("TP" + "TN", "TP" + "TN" + "FP" + "FN")
$ <math-accuracy>

Tương tự như mục *3.1* và *3.2*, chúng ta định nghĩa hàm phần thưởng $h$ cho bài toán phân loại là độ chính xác trên toàn bộ tập kiểm thử $cal(D)^"test"$:

$
  h(S) = frac("TP"(S) + "TN"(S), "TP"(S) + "TN"(S) + "FP"(S) + "FN"(S))
$

trong đó $"TP"(S)$, $"TN"(S)$, $"FP"(S)$, $"FN"(S)$ là số lượng tương ứng khi phân loại toàn bộ tập kiểm thử bằng hàm phân loại $g_S$ được huấn luyện từ hợp của các $cal(Q)_k$ với $k in S subset.eq N$. Áp dụng cách xấp xỉ tương tự như @math-shapley-value-hindsight-local, Giá trị Shapley cho cụm dữ liệu $k$ trong bài toán phân loại được xấp xỉ như sau:

$
  hat(phi)_k = 1/M sum_(m=1)^M [h("Pre"^k (cal(O)^m) union {k}) - h("Pre"^k (cal(O)^m))]
$ <math-shapley-value-hindsight-classification>

#pagebreak()

= Chương 4. KẾT QUẢ NGHIÊN CỨU VÀ PHÂN TÍCH, ĐÁNH GIÁ, THẢO LUẬN

== 4.1. Dữ liệu tạo sinh

Trước khi sử dụng dữ liệu thực tế, chúng ta sẽ thử nghiệm phương pháp đề xuất ở Chương 3 trên tập dữ liệu tạo sinh (synthetic data). Ưu điểm của dữ liệu tạo sinh là chúng ta biết chính xác quy luật tạo sinh dữ liệu: hàm quyết định, phân phối nhiễu cũng như mối quan hệ giữa các cụm dữ liệu. Nhờ đó, chúng ta có thể thiết kế các cụm với những tính chất đã biết trước, rồi kiểm chứng xem Giá trị Shapley cho cụm dữ liệu có phản ánh đúng các tính chất lý thuyết đã trình bày ở Chương 2 và Chương 3 hay không, trước khi áp dụng phương pháp vào dữ liệu thực tế vốn không có thông tin sẵn có như vậy.

Chúng ta đề xuất một bài toán hồi quy mô phỏng theo chuỗi thời gian đơn giản:

$
  x_j(t) = sin(omega_j t) + eta_j(t), quad j = 1, dots, 4
$ <math-synthetic-x>

trong đó:

- $t = 1, dots, T$ là các bước thời gian.
- $eta_j(t) tilde cal(N)(0, 0.1)$ là biến ngẫu nhiên theo phân phối chuẩn cộng vào từng thời điểm $t$.
- $omega_j$ được lấy mẫu theo phân phối đều (uniform) trong khoảng $[0, 2 pi]$. Trong thực nghiệm, để kết quả có thể tái lập được, các biến $omega_j$ được chọn cố định cho từng đặc trưng thay vì lấy mẫu ngẫu nhiên. Bốn đặc trưng được thiết kế để dao động với tần số khác nhau rõ rệt để dễ nhận diện.

Dựa vào đó, định nghĩa hàm sinh dữ liệu:

$
  y(t) = x_1(t) dot x_2(t) + x_3(t) dot x_4(t) + epsilon(t)
$ <math-synthetic-y>

trong đó:

- $x_j$ là các biến giải thích (explanatory variables)
- Biến gây nhiễu $epsilon(t)$ độc lập và có cùng phân phối (i.i.d.) với $cal(N)(0, 0.1)$

Khác với dữ liệu thực tế, ở đây chúng ta biết chính xác rằng $y$ chỉ được sinh từ hàm phi tuyến $x_1 dot x_2 + x_3 dot x_4$ kết hợp 2 cặp đặc trưng $(x_1, x_2)$ và $(x_3, x_4)$; do đó mọi sai số dự đoán của mô hình so với $y$ đều bắt nguồn từ 2 nguồn: nhiễu $epsilon$ và những vùng dữ liệu mà mô hình học chưa tốt. Dữ liệu tạo sinh này sẽ dùng để huấn luyện 2 mô hình:

- Mô hình *Random Forest*, với 100 cây và số lượng nút lá tối đa mỗi cây là 30.
- Mô hình *KNN* với $k = 10$ (*KNN-10*).

Khi giải thích các dự đoán, chúng ta sẽ không đưa mô hình đã huấn luyện vào trong lời giải thích (mô hình *Random Forest* hay *KNN*) vì chúng ta xem các mô hình này là những hộp đen. Bên cạnh đó, chúng ta sẽ không can thiệp hoặc kiểm tra mô hình được dùng để tạo ra các dự đoán đó mà chỉ sử dụng để huấn luyện lại với tập dữ liệu mới, kể cả việc không chỉnh sửa các siêu tham số (hyper-parameter) trong mô hình.

=== 4.1.1. Khởi tạo dữ liệu

Chúng ta mô phỏng 400 điểm dữ liệu từ mô hình trên để tạo thành tập huấn luyện, sau đó chia tiếp thành 4 cụm, mỗi cụm chứa 100 điểm dữ liệu. Tiếp theo, tạo cụm dữ liệu thứ 5 có toàn bộ điểm dữ liệu giống với cụm dữ liệu thứ 4. Lúc này tập huấn luyện bao gồm 500 điểm dữ liệu và 5 cụm $cal(Q)_1, ..., cal(Q)_5$. Mục đích của việc cụm dữ liệu thứ 4 và thứ 5 giống nhau là để minh hoạ tính đối xứng của Giá trị Shapley (@math-shapley-value-symmetry): khi 2 cụm dữ liệu huấn luyện giống nhau, Giá trị Shapley của chúng cũng bằng nhau $phi_4 = phi_5$.

Bởi vì về bản chất mỗi phương pháp giải thích đều mang tính chủ quan nên rất khó để kiểm tra độ tin cậy cũng như tính chính xác. Để giải quyết vấn đề này, @hall2018introduction đề xuất dùng dữ liệu kiểm thử với hàm sinh dữ liệu đã biết trước, qua đó kiểm tra xem lời giải thích có phản ánh đúng hàm sinh dữ liệu hay không. Do đó trong ví dụ này, chúng ta tạo tập kiểm thử giống với tập huấn luyện. Tất nhiên điều này không bao giờ xảy ra trong thực tế, nhưng mục đích trong ví dụ này là để chúng ta hiểu được phương pháp cũng như đánh giá phương pháp giải thích có hợp lý hay không nên việc đặt tập kiểm thử trùng với tập huấn luyện là hợp lý giúp đánh giá chất lượng của lời giải thích dễ dàng hơn.

@figure-synthetic-train-data minh hoạ tập dữ liệu: 5 cụm khác nhau được thể hiện bởi 5 màu khác nhau. Mỗi cụm có 100 điểm dữ liệu. Cụm dữ liệu thứ 4 và thứ 5 giống nhau nên có hình dạng giống nhau. Trên cùng là biểu đồ thể hiện giá trị $y$ theo thời gian, tiếp theo là 4 biểu đồ thể hiện các đặc trưng $x_1, x_2, x_3, x_4$ theo thời gian.

#figure(
  image("figures/synthetic_00_train_data.png"),
  caption: [Dữ liệu huấn luyện của tập dữ liệu tạo sinh],
) <figure-synthetic-train-data>

=== 4.1.2. Giải thích dự đoán (predictions)

Trước khi chuyển sang giải thích sai số bình phương, chúng ta trình bày kết quả giải thích cho dự đoán (predictions). @figure-synthetic-predictions-selected-rf thể hiện Giá trị Shapley của từng cụm dữ liệu huấn luyện đối với dự đoán của mô hình *Random Forest* cho 5 điểm dữ liệu được chọn trong tập kiểm thử, cụ thể:

- Biểu đồ trên cùng thể hiện giá trị dự đoán được vẽ cho toàn bộ 500 điểm của tập kiểm thử, trùng với tập huấn luyện được minh hoạ trong @figure-synthetic-train-data $cal(D)^"test" = cal(D)^"train"$, đồng thời chọn ra 5 điểm dữ liệu với $t = 50, 150, 250, 350, 450$ được đánh dấu màu đỏ để minh hoạ Giá trị Shapley. Dự đoán được tạo ra bởi mô hình $f_N$ (*Random Forest*) được huấn luyện trên toàn bộ tập huấn luyện.
- Các biểu đồ ở giữa từ trái qua phải lần lượt là kết quả giải thích cho 5 điểm dữ liệu được chọn. Mỗi biểu đồ vẽ Giá trị Shapley ước lượng cho mức độ quan trọng của 5 cụm dữ liệu được minh hoạ dưới dạng biểu đồ cột với màu tương ứng của từng cụm.
- Các biểu đồ ở hàng dưới cùng cho thấy Giá trị Shapley của từng cụm dữ liệu thay đổi khi số mẫu $m$ tăng từ 1 đến $M = 250$, mỗi lần lặp $m$ được thực hiện tương tự như @algorithm-shapley-value-hindsight nhưng với hàm phần thưởng là dự đoán thay vì sai số bình phương.

#figure(
  image("figures/synthetic_02_predictions_selected.png"),
  caption: [Giải thích dự đoán cho các điểm dữ liệu $t = 50, 150, 250, 350, 450$ bằng Giá trị Shapley cho độ quan trọng của cụm dữ liệu với mô hình *Random Forest*. 5 Giá trị Shapley tính bởi 5 cụm dữ liệu là 5 màu khác nhau],
) <figure-synthetic-predictions-selected-rf>

Như đã trình bày từ trước, trong trò chơi của chúng ta, các cụm dữ liệu huấn luyện đóng vai người chơi và dự đoán là phần thưởng. Do đó, chúng ta diễn giải Giá trị Shapley của một cụm dữ liệu là mức đóng góp của cụm đó vào dự đoán. Ví dụ, xét điểm dữ liệu đầu tiên tại thời điểm $t = 50$, Giá trị Shapley cho thấy cụm dữ liệu $Q_1$ đóng góp làm tăng dự đoán, trong khi đóng góp của 4 cụm còn lại làm giảm dự đoán. Dự đoán tại 2 điểm dữ liệu tiếp theo, $t = 150$ và $t = 250$, đóng góp của cụm dữ liệu $Q_2$ và $Q_3$ lần lượt làm giảm đáng kể, kết quả giá trị dự đoán cả 2 điểm này cũng đều là số âm. Tại 2 điểm dữ liệu cuối có Giá trị Shapley giống hệt nhau, phù hợp với tính chất đối xứng của Giá trị Shapley ở @math-shapley-value-symmetry. Giá trị cụ thể của từng điểm dữ liệu được trình bày trong @table-synthetic-predictions-selected-rf.

#figure(
  table(
    columns: 6,
    align: (left, center, center, center, center, center),
    [*Cụm dữ liệu $Q_k$*], [*$t = 50$*], [*$t = 150$*], [*$t = 250$*], [*$t = 350$*], [*$t = 450$*],

    ..range(1, 6)
      .map(k => (
        [$Q_#k$],
        ..csv("results/synthetic_01_predictions_phi_selected.csv")
          .slice(1)
          .filter(row => int(row.first()) in (50, 150, 250, 350, 450))
          .map(row => round_3(float(row.at(k)))),
      ))
      .flatten(),
  ),
  caption: [
    Giá trị Shapley cục bộ tại 5 điểm dữ liệu được chọn với mô hình *Random Forest*
  ],
) <table-synthetic-predictions-selected-rf>

Áp dụng mục *3.2* để tính Giá trị Shapley toàn cục cho từng cụm dữ liệu. @figure-synthetic-predictions-number-iterations-rf trình bày sự hội tụ của Giá trị Shapley toàn cục cho từng cụm theo số lần lặp $m$. Nhận thấy giá trị bắt đầu ổn định từ lần lặp $m = 150$ trở đi. Bên cạnh đó, đường biểu diễn giá trị của cụm dữ liệu $Q_4$ gần như trùng với đường biểu diễn giá trị của cụm dữ liệu $Q_5$, phù hợp với tính chất đối xứng của Giá trị Shapley ở @math-shapley-value-symmetry. Giá trị cụ thể của từng cụm dữ liệu được trình bày trong @table-synthetic-predictions-phi-global-rf.

#figure(
  image("figures/synthetic_01_predictions_number_iterations.png"),
  caption: [Sự hội tụ của Giá trị Shapley toàn cục của từng cụm dữ liệu theo số lần lặp $m$ từ 1 đến $M = 250$ trên tập dữ liệu tạo sinh với mô hình *Random Forest*],
) <figure-synthetic-predictions-number-iterations-rf>

#figure(
  table(
    columns: 2,
    align: (left, right),
    [*Cụm dữ liệu $Q_k$*], [*Giá trị Shapley $phi_k$*],

    ..csv("results/synthetic_00_predictions_phi_global.csv")
      .slice(1)
      .map(row => ([$Q_#int(row.first().slice(8))$], round_3(float(row.at(1)))))
      .flatten(),
  ),
  caption: [Giá trị Shapley toàn cục của từng cụm dữ liệu với mô hình *Random Forest* tại lần lặp cuối $M = 250$],
) <table-synthetic-predictions-phi-global-rf>

Để minh chứng tính độc lập với mô hình (model agnostic), chúng ta lặp lại thí nghiệm giải thích dự đoán ở trên với một mô hình hộp đen hoàn toàn khác là *KNN-10*. Toàn bộ cấu hình: dữ liệu huấn luyện, cách phân cụm, và số lần lặp tối đa $M = 250$ được giữ nguyên.

@figure-synthetic-predictions-selected-knn10 thể hiện Giá trị Shapley của từng cụm dữ liệu huấn luyện đối với dự đoán của mô hình *KNN-10* cho cùng 5 điểm dữ liệu được chọn. Tương tự như với mô hình *Random Forest*, cụm dữ liệu $Q_1$ đóng góp làm tăng dự đoán tại điểm dữ liệu đầu tiên, trong khi các cụm còn lại đóng góp làm giảm dự đoán. Dự đoán tại 2 điểm dữ liệu $t = 150$ và $t = 250$ bị giảm đáng kể bởi cụm dữ liệu $Q_2$ và $Q_3$ tương ứng. Tại 2 điểm dữ liệu cuối có Giá trị Shapley giống hệt nhau, minh hoạ tính chất đối xứng của Giá trị Shapley ở @math-shapley-value-symmetry. Giá trị cụ thể của từng điểm dữ liệu được trình bày trong @table-synthetic-predictions-selected-knn10.

#figure(
  image("figures/synthetic_04_predictions_selected_knn10.png"),
  caption: [Giải thích dự đoán cho các điểm dữ liệu $t = 50, 150, 250, 350, 450$ bằng Giá trị Shapley cho độ quan trọng của cụm dữ liệu với mô hình *KNN-10*],
) <figure-synthetic-predictions-selected-knn10>

#figure(
  table(
    columns: 6,
    align: (left, center, center, center, center, center),
    [*Cụm dữ liệu $Q_k$*], [*$t = 50$*], [*$t = 150$*], [*$t = 250$*], [*$t = 350$*], [*$t = 450$*],

    ..range(1, 6)
      .map(k => (
        [$Q_#k$],
        ..csv("results/synthetic_04_predictions_phi_selected_knn10.csv")
          .slice(1)
          .filter(row => int(row.first()) in (50, 150, 250, 350, 450))
          .map(row => round_3(float(row.at(k)))),
      ))
      .flatten(),
  ),
  caption: [
    Giá trị Shapley cục bộ tại 5 điểm dữ liệu được chọn với mô hình *KNN-10*
  ],
) <table-synthetic-predictions-selected-knn10>

Áp dụng mục *3.2* để tính Giá trị Shapley toàn cục cho từng cụm dữ liệu với mô hình *KNN-10*. @figure-synthetic-predictions-number-iterations-knn10 trình bày sự hội tụ của Giá trị Shapley toàn cục cho từng cụm theo số lần lặp $m$. Tương tự như với mô hình *Random Forest*, giá trị bắt đầu ổn định từ lần lặp $m = 150$ trở đi, và đường biểu diễn giá trị của cụm dữ liệu $Q_4$ gần như trùng với đường biểu diễn giá trị của cụm dữ liệu $Q_5$, phù hợp với tính chất đối xứng của Giá trị Shapley ở @math-shapley-value-symmetry. Giá trị cụ thể của từng cụm dữ liệu được trình bày trong @table-synthetic-predictions-phi-global-knn10.

#figure(
  image("figures/synthetic_03_predictions_number_iterations_knn10.png"),
  caption: [Sự hội tụ của Giá trị Shapley toàn cục của từng cụm dữ liệu theo số lần lặp $m$ từ 1 đến $M = 250$ với mô hình *KNN-10* trên tập dữ liệu tạo sinh],
) <figure-synthetic-predictions-number-iterations-knn10>

#figure(
  table(
    columns: 2,
    align: (left, right),
    [*Cụm dữ liệu $Q_k$*], [*Giá trị Shapley $phi_k$*],

    ..csv("results/synthetic_03_predictions_phi_global_knn10.csv")
      .slice(1)
      .map(row => ([$Q_#int(row.first().slice(8))$], round_3(float(row.at(1)))))
      .flatten(),
  ),
  caption: [Giá trị Shapley toàn cục của từng cụm dữ liệu với mô hình *KNN-10* tại lần lặp cuối $M = 250$],
) <table-synthetic-predictions-phi-global-knn10>

=== 4.1.3. Giải thích sai số bình phương (squared error)

Tương tự với mục *4.1.2*, @figure-synthetic-squared-error-selected-rf trình bày các kết quả giải thích sai số bình phương (squared error) của dự đoán, theo công thức đã trình bày ở mục *3.1*, cho 5 điểm dữ liệu $t = 50, 150, 250, 350, 450$. Các Giá trị Shapley này cho thấy từng cụm dữ liệu đóng góp như thế nào đến sai số bình phương tại 5 điểm dữ liệu được chọn. Lưu ý rằng kết quả này đòi hỏi biết trước giá trị thực tế $y$ (hindsight) tương ứng của mỗi điểm.

#figure(
  image("figures/synthetic_06_squared_error_selected.png"),
  caption: [Giải thích sai số bình phương cho các điểm dữ liệu $t = 50, 150, 250, 350, 450$ bằng Giá trị Shapley cho độ quan trọng của cụm dữ liệu với mô hình *Random Forest*],
) <figure-synthetic-squared-error-selected-rf>

Tương tự với mục *4.1.2*, chúng ta chọn tập kiểm thử trùng với tập huấn luyện $cal(D)^"test" = cal(D)^"train"$. Đối với mô hình *Random Forest*, kết quả dự đoán sẽ tốt hơn nếu dữ liệu kiểm thử trùng với dữ liệu huấn luyện. Vì vậy có thể diễn giải rằng với bất kỳ điểm dữ liệu $x$ thuộc cụm $Q_k$ nào đó, việc đưa cụm $Q_k$ vào tập huấn luyện sẽ làm giảm sai số dự đoán, làm cho sai số tiến về 0, và do đó Giá trị Shapley của cụm $Q_k$, $phi_k$ sẽ là số *âm*.

Ví dụ ở trong @figure-synthetic-squared-error-selected-rf, đối với điểm dữ liệu $t = 150$ thuộc cụm $Q_2$, khi tính sai số bình phương của điểm $t = 150$ trong tập kiểm thử, Giá trị Shapley của cụm dữ liệu $Q_2$ là số âm. Điều này đúng như kỳ vọng vì cụm dữ liệu $Q_2$ đóng góp làm giảm sai số bình phương. Tiếp theo có thể thấy kết quả giải thích tại thời điểm $t = 350$ và $t = 450$ cho thấy cụm dữ liệu $Q_3$ của tập huấn luyện đóng góp làm tăng sai số bình phương, và do đó làm giảm độ chính xác của dự đoán. Điều này là đúng với kỳ vọng bởi vì $t = 350$ và $t = 450$ thuộc cụm dữ liệu $Q_4$ và $Q_5$ không hề liên quan đến cụm dữ liệu $Q_3$. Giá trị Shapley tại điểm dữ liệu $t = 350$ và $t = 450$ cũng giống nhau, phù hợp với tính chất đối xứng của Giá trị Shapley ở @math-shapley-value-symmetry. Cụ thể, Giá trị Shapley của từng điểm dữ liệu được trình bày trong @table-synthetic-squared-error-selected-rf.

#figure(
  table(
    columns: 6,
    align: (left, center, center, center, center, center),
    [*Cụm dữ liệu $Q_k$*], [*$t = 50$*], [*$t = 150$*], [*$t = 250$*], [*$t = 350$*], [*$t = 450$*],

    ..range(1, 6)
      .map(k => (
        [$Q_#k$],
        ..csv("results/synthetic_07_squared_error_phi_selected.csv")
          .slice(1)
          .filter(row => int(row.first()) in (50, 150, 250, 350, 450))
          .map(row => round_3(float(row.at(k)))),
      ))
      .flatten(),
  ),
  caption: [
    Giá trị Shapley cục bộ tại 5 điểm dữ liệu được chọn cho trò chơi giải thích sai số bình phương với mô hình *Random Forest*
  ],
) <table-synthetic-squared-error-selected-rf>

Áp dụng mục *3.2* để tính Giá trị Shapley toàn cục cho từng cụm dữ liệu cho trò chơi sai số bình phương. @figure-synthetic-squared-error-number-iterations-rf trình bày sự hội tụ của Giá trị Shapley toàn cục cho từng cụm theo số lần lặp $m$. Đường biểu diễn giá trị của cụm dữ liệu $Q_4$ gần như trùng với đường biểu diễn giá trị của cụm dữ liệu $Q_5$, phù hợp với tính chất đối xứng của Giá trị Shapley ở @math-shapley-value-symmetry. Giá trị cụ thể của từng cụm dữ liệu được trình bày trong @table-synthetic-squared-error-phi-global-rf.

#figure(
  image("figures/synthetic_05_squared_error_number_iterations.png"),
  caption: [Sự hội tụ của Giá trị Shapley toàn cục của từng cụm dữ liệu theo số lần lặp $m$ từ 1 đến $M = 250$ cho trò chơi sai số bình phương trên tập dữ liệu tạo sinh với mô hình *Random Forest*],
) <figure-synthetic-squared-error-number-iterations-rf>

#figure(
  table(
    columns: 2,
    align: (left, right),
    [*Cụm dữ liệu $Q_k$*], [*Giá trị Shapley $phi_k$*],

    ..csv("results/synthetic_06_squared_error_phi_global.csv")
      .slice(1)
      .map(row => ([$Q_#int(row.first().slice(8))$], round_3(float(row.at(1)))))
      .flatten(),
  ),
  caption: [Giá trị Shapley toàn cục của từng cụm dữ liệu cho trò chơi giải thích sai số bình phương với mô hình *Random Forest* tại lần lặp cuối $M = 250$],
) <table-synthetic-squared-error-phi-global-rf>

Để minh chứng tính độc lập với mô hình (model agnostic), chúng ta lặp lại thí nghiệm giải thích sai số bình phương ở trên với mô hình *KNN-10*. Toàn bộ cấu hình: dữ liệu huấn luyện, cách phân cụm, và số lần lặp tối đa $M = 250$ được giữ nguyên. @figure-synthetic-squared-error-selected-knn10 thể hiện Giá trị Shapley của từng cụm dữ liệu huấn luyện đối với sai số bình phương của mô hình *KNN-10* cho cùng 5 điểm dữ liệu được chọn.

Tương tự với mô hình *Random Forest*, Giá trị Shapley của từng cụm dữ liệu ứng với vị trí của từng điểm dữ liệu đều là số âm: Giá trị Shapley của cụm dữ liệu $Q_1$ tại điểm dữ liệu $t = 50$ thuộc cụm dữ liệu $Q_1$ là số âm, tương tự cho 4 điểm dữ liệu còn lại $t = 150, 250, 350, 450$. Giá trị Shapley tại điểm dữ liệu $t = 350$ và $t = 450$ cũng giống nhau, phù hợp với tính chất đối xứng của Giá trị Shapley ở @math-shapley-value-symmetry. Giá trị cụ thể của từng điểm dữ liệu được trình bày trong @table-synthetic-squared-error-selected-knn10.

#figure(
  image("figures/synthetic_08_squared_error_selected_knn10.png"),
  caption: [Giải thích sai số bình phương cho các điểm dữ liệu $t = 50, 150, 250, 350, 450$ bằng Giá trị Shapley cho độ quan trọng của cụm dữ liệu với mô hình *KNN-10*],
) <figure-synthetic-squared-error-selected-knn10>

#figure(
  table(
    columns: 6,
    align: (left, center, center, center, center, center),
    [*Cụm dữ liệu $Q_k$*], [*$t = 50$*], [*$t = 150$*], [*$t = 250$*], [*$t = 350$*], [*$t = 450$*],

    ..range(1, 6)
      .map(k => (
        [$Q_#k$],
        ..csv("results/synthetic_10_squared_error_phi_selected_knn10.csv")
          .slice(1)
          .filter(row => int(row.first()) in (50, 150, 250, 350, 450))
          .map(row => round_3(float(row.at(k)))),
      ))
      .flatten(),
  ),
  caption: [
    Giá trị Shapley cục bộ tại 5 điểm dữ liệu được chọn cho trò chơi giải thích sai số bình phương với mô hình *KNN-10*
  ],
) <table-synthetic-squared-error-selected-knn10>

Áp dụng mục *3.2* để tính Giá trị Shapley toàn cục cho từng cụm dữ liệu cho trò chơi sai số bình phương với mô hình *KNN-10*. @figure-synthetic-squared-error-number-iterations-knn10 trình bày sự hội tụ của Giá trị Shapley toàn cục cho từng cụm theo số lần lặp $m$. Tương tự với mô hình *Random Forest*, đường biểu diễn giá trị của cụm dữ liệu $Q_4$ và đường biểu diễn giá trị của cụm dữ liệu $Q_5$ gần bằng nhau, phù hợp với tính chất đối xứng của Giá trị Shapley ở @math-shapley-value-symmetry. Giá trị cụ thể của từng cụm dữ liệu được trình bày trong @table-synthetic-squared-error-phi-global-knn10.

#figure(
  image("figures/synthetic_07_squared_error_number_iterations_knn10.png"),
  caption: [Sự hội tụ của Giá trị Shapley toàn cục của từng cụm dữ liệu theo số lần lặp $m$ từ 1 đến $M = 250$ với mô hình *KNN-10* cho trò chơi sai số bình phương trên tập dữ liệu tạo sinh],
) <figure-synthetic-squared-error-number-iterations-knn10>

#figure(
  table(
    columns: 2,
    align: (left, right),
    [*Cụm dữ liệu $Q_k$*], [*Giá trị Shapley $phi_k$*],

    ..csv("results/synthetic_09_squared_error_phi_global_knn10.csv")
      .slice(1)
      .map(row => ([$Q_#int(row.first().slice(8))$], round_3(float(row.at(1)))))
      .flatten(),
  ),
  caption: [Giá trị Shapley toàn cục của từng cụm dữ liệu cho trò chơi giải thích sai số bình phương với mô hình *KNN-10* tại lần lặp cuối $M = 250$],
) <table-synthetic-squared-error-phi-global-knn10>

=== 4.1.4. Phân loại (classification)

Để minh hoạ mục *3.3*, Giá trị Shapley của cụm dữ liệu trong bài toán phân loại, chúng ta vẫn sử dụng lại tập dữ liệu tạo sinh nhưng sẽ thay đổi một vài điểm dữ liệu của $cal(D)^"test"$ bằng các điểm dữ liệu bất thường (anomaly).

Cụ thể, một vài điểm dữ liệu thuộc đặc trưng $x_1$ được thay bằng $x_1^*$:

$
  x_1^* = x_1 + eta^*, quad t in [200, 250)
$ <math-anomaly-x1>

và một vài điểm dữ liệu thuộc đặc trưng $x_4$ được thay bằng $x_4^*$:

$
  x_4^* = x_4 + eta^*, quad t in [300, 350)
$ <math-anomaly-x4>

trong đó $eta^* tilde cal(N)(-0.5, 0.5)$.

Như vậy, tổng cộng có 100 điểm dữ liệu bị thay đổi (với $t in [200, 250) union [300, 350)$), và 400 điểm còn lại được giữ nguyên, 50 điểm thuộc cụm dữ liệu $Q_3$, 50 điểm còn lại thuộc cụm dữ liệu $Q_4$. Tập kiểm thử mới được minh hoạ trong @figure-synthetic-test-anomalies, các điểm bị thay đổi được tô màu đỏ. 100 điểm bị thay đổi được coi là bất thường, 400 điểm còn lại được coi là bình thường.

#figure(
  image("figures/synthetic_09_classification_test_data_anomalies.png"),
  caption: [Tập kiểm thử của tập dữ liệu tạo sinh với các điểm bất thường được tô màu đỏ: $x_1$ bị thay đổi với $t in [200, 250)$ và $x_4$ bị thay đổi với $t in [300, 350)$],
) <figure-synthetic-test-anomalies>

Định nghĩa phân loại:

- TP: Điểm bất thường được phát hiện là điểm bất thường.
- TN: Điểm bình thường được phát hiện là điểm bình thường.
- FN: Điểm bất thường được phát hiện là điểm bình thường.
- FP: Điểm bình thường được phát hiện là điểm bất thường.

Định nghĩa hàm phân loại $g(t)$ là dự đoán có hay không điểm bất thường tại thời điểm $t$ trong tập kiểm thử. Để làm điều đó, chúng ta áp dụng một phương pháp thuộc loại tái tạo tín hiệu đa biến kết hợp với phân tích phần dư (multivariate signal reconstruction followed by residuals
analysis), cụ thể là *AAKR* @Jung2021. Tổng quan thì phương pháp này so sánh tín hiệu gốc với một bản tái tạo (reconstruction): nếu bản tái tạo có sự khác biệt với tín hiệu gốc, và giá trị khác biệt đủ lớn (vượt quá một ngưỡng $L$ cho trước), điểm dữ liệu được phân loại là bất thường; ngược lại nếu nhỏ hơn ngưỡng thì điểm dữ liệu được phân loại là bình thường.

Cụ thể, cách hoạt động của *AAKR* là so sánh độ tương đồng giữa dữ liệu kiểm thử với dữ liệu huấn luyện, dữ liệu mẫu nào càng giống thì càng được gán trọng số cao để tính ra giá trị ước lượng [TODO explain]. *AAKR* có tham số băng thông (bandwidth) $h$ dùng để kiểm soát trọng số. Có nhiều kỹ thuật để tinh chỉnh và tối ưu hóa tham số này, nhưng vì mục tiêu của nghiên cứu là thử nghiệm minh họa Giá trị Shapley chứ không đào sâu vào cải tiến hay thử nghiệm thuật toán của mô hình nên chúng ta chọn $h = 0.2$ và ngưỡng giới hạn $L = 0.5$ làm ranh giới để phân loại giữa trạng thái bình thường và bất thường [TODO explain]. @figure-synthetic-classification-compare-train-aakr và @figure-synthetic-classification-compare-test-aakr minh hoạ tín hiệu ước lượng được tái tạo bởi *AAKR* trên tập huấn luyện và tập kiểm thử, tín hiệu tái tạo bởi *AAKR* được vẽ bằng màu vàng.

#figure(
  image("figures/synthetic_10_classification_compare_train_aakr.png"),
  caption: [So sánh tập huấn luyện với tín hiệu ước lượng được tái tạo bởi *AAKR* trên tập dữ liệu tạo sinh],
) <figure-synthetic-classification-compare-train-aakr>

#figure(
  image("figures/synthetic_11_classification_compare_test_aakr.png"),
  caption: [So sánh tập kiểm thử với tín hiệu ước lượng được tái tạo bởi *AAKR* trên tập dữ liệu tạo sinh],
) <figure-synthetic-classification-compare-test-aakr>

Sau khi tất cả các điểm dữ liệu trong tập kiểm thử được phân loại là bình thường hoặc bất thường bởi hàm phân loại $g(t)$, chúng ta sẽ so sánh với giá trị thực tế của chúng. Ví dụ, nếu $g$ phân loại điểm dữ liệu tại $t = 225$ là bất thường, đây là một TP, vì điểm này đã bị chúng ta thay đổi bởi @math-anomaly-x1 nên trạng thái thực tế của nó chính là bất thường. Dựa trên số lượng TP, TN, FP, FN, chúng ta có thể tính được độ chính xác $h$ theo @math-accuracy:

$
  h = frac("TP" + "TN", "TP" + "TN" + "FP" + "FN")
$ <math-accuracy-classification>

Để tính được mức độ đóng góp của 5 cụm dữ liệu vào độ chính xác, chúng ta sử dụng công thức @math-shapley-value-hindsight-classification được trình bày ở mục *3.3*. Vì tập kiểm thử và tập huấn luyện gần như giống hệt nhau, ngoại trừ 100 điểm bất thường nằm trong cụm dữ liệu $Q_3$ và $Q_4$, do đó chúng ta kỳ vọng cụm dữ liệu $Q_1$ và $Q_2$ đóng góp nhiều hơn cụm dữ liệu $Q_3$ vào việc tăng độ chính xác; bên cạnh đó vì cụm dữ liệu $Q_4$ và $Q_5$ có dữ liệu giống nhau, Giá trị Shapley của chúng phải bằng nhau theo tính chất đối xứng ở @math-shapley-value-symmetry. Kết quả thực tế ở @table-synthetic-classification-phi-global cho thấy cụm dữ liệu $Q_1$ và $Q_2$ có Giá trị Shapley cao nhất ($phi_1 = 0.235$ và $phi_2 = 0.223$), tiếp theo là cụm dữ liệu $Q_4$ và $Q_5$ với Giá trị Shapley gần như bằng nhau ($phi_4 = 0.165$ và $phi_5 = 0.159$), và cuối cùng cụm dữ liệu $Q_3$ có Giá trị Shapley thấp nhất ($phi_3 = 0.099$).
@figure-synthetic-classification-number-iterations trình bày sự hội tụ của Giá trị Shapley toàn cục cho từng cụm theo số lần lặp $m$.

#figure(
  table(
    columns: 2,
    align: (left, right),
    [*Cụm dữ liệu $Q_k$*], [*Giá trị Shapley $phi_k$*],

    ..csv("results/synthetic_12_classification_phi_global.csv")
      .slice(1)
      .map(row => ([$Q_#int(row.first().slice(8))$], round_3(float(row.at(1)))))
      .flatten(),
  ),
  caption: [Giá trị Shapley toàn cục của từng cụm dữ liệu cho trò chơi giải thích độ chính xác phân loại tại lần lặp cuối $M = 250$],
) <table-synthetic-classification-phi-global>

#figure(
  image("figures/synthetic_12_classification_number_iterations.png"),
  caption: [Sự hội tụ của Giá trị Shapley toàn cục của từng cụm dữ liệu theo số lần lặp $m$ từ 1 đến $M = 250$ cho độ chính xác phân loại trên tập dữ liệu tạo sinh],
) <figure-synthetic-classification-number-iterations>

== 4.2. Dữ liệu Bikeshare

Sau khi kiểm chứng phương pháp đề xuất trên dữ liệu tạo sinh, chúng ta tiếp tục thử nghiệm trên một tập dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng Bikeshare @bike_sharing_275. Tập dữ liệu Bikeshare được cung cấp sẵn trong gói thư viện *ISLR2* @ISLR2 của ngôn ngữ R, ghi nhận số lượt thuê xe đạp theo từng giờ trong hệ thống xe đạp công cộng tại thành phố Washington D.C., Hoa Kỳ trong 2 năm 2011 và 2012; mỗi quan sát tương ứng với một giờ cụ thể, kèm theo số lượt thuê xe trong giờ đó cùng các thông tin về thời điểm và điều kiện thời tiết tại giờ đó. Sau khi loại bỏ các quan sát không đầy đủ, tập dữ liệu gồm 8645 điểm dữ liệu. Khác với dữ liệu tạo sinh ở mục *4.1* vốn được sinh ra từ một hàm toán học biết trước, mối quan hệ giữa các đặc trưng và số lượt thuê xe ở đây không tuân theo công thức nào cả mà chịu ảnh hưởng đồng thời của nhiều yếu tố như giờ trong ngày, ngày làm việc và điều kiện thời tiết, đồng thời có thể thay đổi theo thời gian. Chính vì vậy, tập dữ liệu này phù hợp để đánh giá khả năng giải thích sai số dự đoán của phương pháp trong điều kiện thực tế, nơi nguồn gốc của sai số thường đến từ những vùng dữ liệu khó dự đoán thay vì nhiễu ngẫu nhiên có phân phối đã biết.

Bài toán đặt ra là làm thế nào để dự đoán số lượt thuê xe đạp $y$ dựa trên các đặc trưng đầu vào. Chúng ta sử dụng các đặc trưng có sẵn và có ý nghĩa thực tế của tập dữ liệu, được liệt kê trong @table-bikeshare-variables. Trong đó, 8 đặc trưng $x_1, ..., x_8$ đóng vai trò là biến đầu vào của mô hình dự đoán, còn $x_S$ (tháng) không được đưa vào mô hình mà chỉ dùng làm khóa để phân cụm dữ liệu được trình bày ngay sau đây.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    [*Ký hiệu*], [*Đặc trưng*], [*Mô tả*],

    [$y$], [bikers], [Số lượt thuê xe đạp],
    [$x_1$], [hr], [Giờ trong ngày],
    [$x_2$], [holiday], [Ngày lễ hay không],
    [$x_3$], [weekday], [Thứ mấy trong tuần],
    [$x_4$], [workingday], [Ngày làm việc hay không],
    [$x_5$], [weathersit], [Tình trạng thời tiết],
    [$x_6$], [temp], [Nhiệt độ],
    [$x_7$], [hum], [Độ ẩm],
    [$x_8$], [windspeed], [Tốc độ gió],
    [$x_S$], [mnth], [Tháng],
  ),
  caption: [Các biến được sử dụng trong tập dữ liệu Bikeshare],
) <table-bikeshare-variables>

Tập dữ liệu huấn luyện được chia thành $K$ cụm dữ liệu theo tháng trong năm $cal(Q)_1, ..., cal(Q)_K$ với $K = 12$, trong đó $cal(Q)_k$ bao gồm toàn bộ quan sát có $x_S = k$. Như đã trình bày ở mục *1.5*, nghiên cứu không đề xuất cách phân cụm mới mà cố gắng sử dụng cách phân cụm tự nhiên có sẵn của dữ liệu nếu có thể. Ở đây, yếu tố thời gian theo tháng là lựa chọn dễ thấy nhất: nhu cầu sử dụng xe đạp công cộng mang tính thời vụ rõ rệt, tăng vào những tháng mùa hè và giảm vào những tháng mùa đông, nên việc phân cụm theo tháng giúp các câu hỏi giải thích trở nên có ý nghĩa thực tế, ví dụ như cụm dữ liệu của tháng nào gây ra sai số dự đoán lớn nhất. Bên cạnh đó, vì mỗi tháng có số ngày gần bằng nhau, số quan sát trong mỗi cụm khá cân bằng, dao động từ ít nhất 649 quan sát (tháng 2) đến nhiều nhất 744 quan sát (tháng 5 và tháng 7); sự cân bằng này giúp mức đóng góp của các cụm có thể so sánh trực tiếp với nhau, không bị chi phối bởi chênh lệch kích thước giữa các cụm. @table-bikeshare-cluster-sizes trình bày số quan sát của từng cụm theo tháng.

#figure(
  table(
    columns: (auto, auto),
    align: (center, right),
    [*Tháng*], [*Số quan sát*],

    [$cal(Q)_1$], [688],
    [$cal(Q)_2$], [649],
    [$cal(Q)_3$], [730],
    [$cal(Q)_4$], [719],
    [$cal(Q)_5$], [744],
    [$cal(Q)_6$], [720],
    [$cal(Q)_7$], [744],
    [$cal(Q)_8$], [731],
    [$cal(Q)_9$], [717],
    [$cal(Q)_(10)$], [743],
    [$cal(Q)_(11)$], [719],
    [$cal(Q)_(12)$], [741],
  ),
  caption: [Số quan sát của từng cụm dữ liệu theo tháng trong tập Bikeshare],
) <table-bikeshare-cluster-sizes>

Để phục vụ huấn luyện và đánh giá, từ các quan sát trong mỗi cụm $cal(Q)_k$, chúng ta lấy ngẫu nhiên 3 tập không giao nhau với tỷ lệ được trình bày trong @table-bikeshare-split. Thứ tự lấy mẫu trong từng cụm như sau: trước tiên 30 quan sát được lấy ra làm tập đánh giá $cal(D)^"eval"$, sau đó 200 quan sát tiếp theo được lấy ra làm tập kiểm thử $cal(D)^"shapley test"$, cuối cùng 400 quan sát được lấy ra làm tập huấn luyện $cal(D)^"shapley train"$; cách lấy tuần tự, mỗi lần loại bỏ các quan sát đã chọn, đảm bảo 3 tập luôn rời nhau từng phần. Phần quan sát còn lại của cụm (từ 19 đến 114 quan sát tùy theo tháng) không tham gia vào quá trình tính Giá trị Shapley.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, right, right),
    [*Tập dữ liệu*], [*Số mẫu mỗi cụm*], [*Tổng số mẫu*],

    [$cal(D)^"shapley train"$], [400], [4800],
    [$cal(D)^"shapley test"$], [200], [2400],
    [$cal(D)^"eval"$], [30], [360],
  ),
  caption: [Phân chia dữ liệu Bikeshare cho từng cụm],
) <table-bikeshare-split>

Tập $cal(D)^"shapley train"$ được dùng làm dữ liệu huấn luyện để phục vụ việc tính Giá trị Shapley, nghĩa là với mỗi hoán vị $cal(O)$ trong thuật toán xấp xỉ, mô hình $f_S$ được huấn luyện lại từ hợp các cụm $cal(Q)_k$ với $k in S$. Tập $cal(D)^"shapley test"$ gồm các điểm dữ liệu $x$ mà tại đó chúng ta tính Giá trị Shapley cục bộ $hat(phi)_k (x)$ theo thuật toán xấp xỉ đã trình bày ở mục *3.1*. Cuối cùng, tập $cal(D)^"eval"$ hoàn toàn tách biệt và chỉ được dùng để đánh giá cuối cùng, nhằm tránh rò rỉ dữ liệu (data leakage) giữa quá trình giải thích và quá trình đánh giá.

Mô hình hộp đen được sử dụng là mô hình *Random Forest*. Tương tự như mục *4.1*, chúng ta giả định không có hiểu biết gì về thuật toán bên trong mô hình, nhưng được phép huấn luyện lại mô hình trong quá trình tính Giá trị Shapley. Các thực nghiệm được thực hiện trên cả 2 chế độ: giải thích trực tiếp giá trị dự đoán $f_S (x)$ và giải thích sai số bình phương của dự đoán theo @math-shapley-value-hindsight-reward-2.

Đối với giai đoạn tính Giá trị Shapley, chúng ta sử dụng $M = 150$ hoán vị ngẫu nhiên theo phân phối đều (uniform). Với mỗi cụm $k$, tập hợp toàn bộ Giá trị Shapley cục bộ $hat(phi)_k (x_t)$ trên $T = 2400$ điểm của tập $cal(D)^"shapley test"$ cho chúng ta Giá trị Shapley toàn cục:

$
  macron(phi)_k = 1/T sum_(t=1)^T hat(phi)_k (x_t)
$ <math-bikeshare-global-phi>

theo *Mệnh đề 1*. Giá trị $macron(phi)_k$ thể hiện mức độ đóng góp trung bình của cụm dữ liệu $k$ vào sai số dự đoán của mô hình. Bên cạnh đó, để minh hoạ tính cục bộ của phương pháp, chúng ta chọn ra 4 tháng trong năm (tháng 1, 4, 8 và 12), tương ứng với 4 điểm dữ liệu $x$, và biểu diễn Giá trị Shapley cục bộ của từng cụm cho từng điểm dữ liệu này, cùng với đồ thị hội tụ của chúng theo số lần lặp $m$.

=== 4.2.1. Giải thích dự đoán (predictions)

@figure-bikeshare-predictions-selected-rf thể hiện Giá trị Shapley của từng cụm dữ liệu huấn luyện đối với dự đoán của mô hình *Random Forest* cho 4 điểm dữ liệu được chọn trong tập kiểm thử $cal(D)^"shapley test"$, tương ứng với 4 tháng 1, 4, 8 và 12, cụ thể $t = 50, 650, 1450, 2250$. Các biểu đồ ở giữa từ trái qua phải lần lượt là kết quả giải thích cho 4 điểm dữ liệu được chọn, mỗi biểu đồ vẽ Giá trị Shapley ước lượng cho mức độ quan trọng của 12 cụm dữ liệu dưới dạng biểu đồ cột; các biểu đồ ở hàng dưới cùng cho thấy Giá trị Shapley của từng cụm dữ liệu thay đổi khi số lần lặp $m$ tăng từ 1 đến $M = 150$.

#figure(
  image("figures/bikeshare_10_predictions_selected.png"),
  caption: [Giải thích dự đoán cho các điểm dữ liệu $t = 50, 650, 1450, 2250$ bằng Giá trị Shapley cho độ quan trọng của cụm dữ liệu với mô hình *Random Forest* trên tập dữ liệu Bikeshare],
) <figure-bikeshare-predictions-selected-rf>

Như đã trình bày từ trước, trong trò chơi của chúng ta, các cụm dữ liệu huấn luyện đóng vai người chơi và dự đoán là phần thưởng. Do đó, chúng ta diễn giải Giá trị Shapley của một cụm dữ liệu là mức đóng góp của cụm đó vào dự đoán. Kết quả cho thấy cụm dữ liệu của các tháng mùa đông $Q_1$, $Q_2$, $Q_3$ có Giá trị Shapley âm tại hầu hết các điểm dữ liệu được chọn, nghĩa là các cụm này làm giảm giá trị dự đoán; ngược lại, các cụm dữ liệu của những tháng mùa hè như $Q_5$, $Q_6$, $Q_9$ có Giá trị Shapley dương lớn, đóng góp làm tăng giá trị dự đoán. Kết quả này phù hợp với tính thời vụ của dữ liệu: số lượt thuê xe đạp thấp vào mùa đông và cao vào mùa hè, nên việc bổ sung dữ liệu huấn luyện của các tháng mùa hè kéo dự đoán tăng lên, trong khi dữ liệu của các tháng lạnh kéo dự đoán giảm xuống. Giá trị cụ thể của từng điểm dữ liệu được trình bày trong @table-bikeshare-predictions-selected-rf.

#figure(
  table(
    columns: 5,
    align: (left, center, center, center, center),
    [*Cụm dữ liệu $Q_k$*], [*$t = 50$*], [*$t = 650$*], [*$t = 1450$*], [*$t = 2250$*],

    ..range(1, 13)
      .map(k => (
        [$Q_#k$],
        ..csv("results/bikeshare_01_predictions_phi_selected.csv")
          .slice(1)
          .filter(row => int(row.first()) in (50, 650, 1450, 2250))
          .map(row => round_3(float(row.at(k)))),
      ))
      .flatten(),
  ),
  caption: [
    Giá trị Shapley cục bộ tại 4 điểm dữ liệu được chọn với mô hình *Random Forest* trên tập dữ liệu Bikeshare
  ],
) <table-bikeshare-predictions-selected-rf>

Áp dụng mục *3.2* để tính Giá trị Shapley toàn cục cho từng cụm dữ liệu. @figure-bikeshare-predictions-number-iterations-rf trình bày sự hội tụ của Giá trị Shapley toàn cục cho từng cụm theo số lần lặp $m$; giá trị bắt đầu ổn định từ khoảng lần lặp $m = 100$ trở đi. Giá trị cụ thể của từng cụm dữ liệu được trình bày trong @table-bikeshare-predictions-phi-global-rf: các cụm dữ liệu mùa đông $Q_1$, $Q_2$, $Q_3$ là duy nhất có Giá trị Shapley âm ($phi_1 = -5.520$, $phi_2 = -3.726$, $phi_3 = -3.456$), trong khi các cụm dữ liệu mùa hè có Giá trị Shapley dương cao nhất ($phi_5 = 25.601$, $phi_6 = 25.031$, $phi_9 = 25.256$).

#figure(
  image("figures/bikeshare_09_predictions_number_iterations.png"),
  caption: [Giá trị Shapley toàn cục của từng cụm dữ liệu theo số lần lặp $m$ từ 1 đến $M = 150$ trên tập dữ liệu Bikeshare với mô hình *Random Forest*],
) <figure-bikeshare-predictions-number-iterations-rf>

#figure(
  table(
    columns: 2,
    align: (left, right),
    [*Cụm dữ liệu $Q_k$*], [*Giá trị Shapley $phi_k$*],

    ..csv("results/bikeshare_00_predictions_phi_global.csv")
      .slice(1)
      .map(row => ([$Q_#int(row.first().slice(8))$], round_3(float(row.at(1)))))
      .flatten(),
  ),
  caption: [Giá trị Shapley toàn cục của từng cụm dữ liệu với mô hình *Random Forest* trên tập dữ liệu Bikeshare tại lần lặp cuối $M = 150$],
) <table-bikeshare-predictions-phi-global-rf>

Để minh chứng tính độc lập với mô hình (model agnostic), chúng ta lặp lại thí nghiệm giải thích dự đoán ở trên với một mô hình hộp đen hoàn toàn khác là *KNN-10*. Toàn bộ cấu hình: dữ liệu huấn luyện, cách phân cụm, và số lần lặp tối đa $M = 150$ được giữ nguyên. @figure-bikeshare-predictions-selected-knn10 thể hiện Giá trị Shapley của từng cụm dữ liệu huấn luyện đối với dự đoán của mô hình *KNN-10* cho cùng 4 điểm dữ liệu được chọn. Tương tự như với mô hình *Random Forest*, các cụm dữ liệu mùa đông $Q_1$, $Q_2$, $Q_3$ có Giá trị Shapley âm tại hầu hết các điểm dữ liệu được chọn, trong khi các cụm dữ liệu mùa hè có Giá trị Shapley dương lớn. Giá trị cụ thể của từng điểm dữ liệu được trình bày trong @table-bikeshare-predictions-selected-knn10.

#figure(
  image("figures/bikeshare_16_predictions_selected_knn10.png"),
  caption: [Giải thích dự đoán cho các điểm dữ liệu $t = 50, 650, 1450, 2250$ bằng Giá trị Shapley cho độ quan trọng của cụm dữ liệu với mô hình *KNN-10* trên tập dữ liệu Bikeshare],
) <figure-bikeshare-predictions-selected-knn10>

#figure(
  table(
    columns: 5,
    align: (left, center, center, center, center),
    [*Cụm dữ liệu $Q_k$*], [*$t = 50$*], [*$t = 650$*], [*$t = 1450$*], [*$t = 2250$*],

    ..range(1, 13)
      .map(k => (
        [$Q_#k$],
        ..csv("results/bikeshare_13_predictions_phi_selected_knn10.csv")
          .slice(1)
          .filter(row => int(row.first()) in (50, 650, 1450, 2250))
          .map(row => round_3(float(row.at(k)))),
      ))
      .flatten(),
  ),
  caption: [
    Giá trị Shapley cục bộ tại 4 điểm dữ liệu được chọn với mô hình *KNN-10* trên tập dữ liệu Bikeshare
  ],
) <table-bikeshare-predictions-selected-knn10>

Áp dụng mục *3.2* để tính Giá trị Shapley toàn cục cho từng cụm dữ liệu với mô hình *KNN-10*. @figure-bikeshare-predictions-number-iterations-knn10 trình bày sự hội tụ của Giá trị Shapley toàn cục cho từng cụm theo số lần lặp $m$; giá trị bắt đầu ổn định từ khoảng lần lặp $m = 100$ trở đi. Tương tự như với mô hình *Random Forest*, các cụm dữ liệu mùa đông $Q_1$, $Q_2$, $Q_3$ là duy nhất có Giá trị Shapley âm ($phi_1 = -9.733$, $phi_2 = -3.335$, $phi_3 = -5.509$), trong khi các cụm dữ liệu mùa hè có Giá trị Shapley dương cao nhất ($phi_7 = 22.425$, $phi_8 = 26.685$, $phi_9 = 22.089$). Thứ tự này phản ánh đúng tính thời vụ theo tháng của nhu cầu sử dụng xe đạp. Giá trị cụ thể của từng cụm dữ liệu được trình bày trong @table-bikeshare-predictions-phi-global-knn10.

#figure(
  image("figures/bikeshare_15_predictions_number_iterations_knn10.png"),
  caption: [Giá trị Shapley toàn cục của từng cụm dữ liệu theo số lần lặp $m$ từ 1 đến $M = 150$ trên tập dữ liệu Bikeshare với mô hình *KNN-10*],
) <figure-bikeshare-predictions-number-iterations-knn10>

#figure(
  table(
    columns: 2,
    align: (left, right),
    [*Cụm dữ liệu $Q_k$*], [*Giá trị Shapley $phi_k$*],

    ..csv("results/bikeshare_12_predictions_phi_global_knn10.csv")
      .slice(1)
      .map(row => ([$Q_#int(row.first().slice(8))$], round_3(float(row.at(1)))))
      .flatten(),
  ),
  caption: [Giá trị Shapley toàn cục của từng cụm dữ liệu với mô hình *KNN-10* trên tập dữ liệu Bikeshare tại lần lặp cuối $M = 150$],
) <table-bikeshare-predictions-phi-global-knn10>

=== 4.2.2. Giải thích sai số bình phương (squared error)

Tương tự với mục *4.1.3*, @figure-bikeshare-squared-error-selected-rf trình bày các kết quả giải thích sai số bình phương (squared error) của dự đoán, theo công thức đã trình bày ở mục *3.1*, cho 4 điểm dữ liệu $t = 50, 650, 1450, 2250$. Lưu ý rằng kết quả này đòi hỏi biết trước giá trị thực tế $y$ (hindsight) tương ứng của mỗi điểm.

#figure(
  image("figures/bikeshare_13_squared_error_selected.png"),
  caption: [Giải thích sai số bình phương cho các điểm dữ liệu $t = 50, 650, 1450, 2250$ bằng Giá trị Shapley cho độ quan trọng của cụm dữ liệu với mô hình *Random Forest* trên tập dữ liệu Bikeshare],
) <figure-bikeshare-squared-error-selected-rf>

Giá trị cụ thể của từng điểm dữ liệu được trình bày trong @table-bikeshare-squared-error-selected-rf. Nhận thấy tại mỗi điểm dữ liệu, các cụm dữ liệu lân cận về thời gian với $t$ có xu hướng đóng góp làm giảm sai số bình phương, trong khi một số cụm ở thời gian xa hơn $t$ có xu hướng đóng góp làm tăng sai số. Ví dụ tại điểm dữ liệu $t = 50$ (tháng 1), các cụm dữ liệu $Q_1$, $Q_2$, $Q_3$ (các tháng mùa đông) có Giá trị Shapley âm mạnh nhất, trong khi các cụm dữ liệu mùa hè như $Q_7$, $Q_8$, $Q_9$ có Giá trị Shapley dương lớn. Tiếp theo, tại điểm dữ liệu $t = 650$ (tháng 4), cụm dữ liệu $Q_4$ (cùng tháng với điểm dữ liệu) cùng các cụm mùa đông lân cận $Q_1$, $Q_3$ đóng góp làm giảm sai số, trong khi các cụm ở xa về thời gian như $Q_5$, $Q_9$, $Q_(12)$ đóng góp làm tăng sai số. Ở điểm dữ liệu $t = 1450$ (tháng 8), cụm $Q_4$ và các cụm lân cận $Q_3$, $Q_6$ giúp giảm sai số bình phương, nhưng các cụm ở xa về thời gian như $Q_5$, $Q_9$, $Q_(10)$ lại làm tăng sai số. Cuối cùng, tại điểm dữ liệu $t = 2250$ (tháng 12), các cụm dữ liệu $Q_1$, $Q_2$, $Q_3$, $Q_(11)$ các tháng lân cận đều có Giá trị Shapley âm, cho thấy dữ liệu của những tháng có điều kiện thời tiết tương tự giúp mô hình dự đoán tốt hơn cho tháng 12.

#figure(
  table(
    columns: 5,
    align: (left, center, center, center, center),
    [*Cụm dữ liệu $Q_k$*], [*$t = 50$*], [*$t = 650$*], [*$t = 1450$*], [*$t = 2250$*],

    ..range(1, 13)
      .map(k => (
        [$Q_#k$],
        ..csv("results/bikeshare_07_squared_error_phi_selected.csv")
          .slice(1)
          .filter(row => int(row.first()) in (50, 650, 1450, 2250))
          .map(row => round_3(float(row.at(k)))),
      ))
      .flatten(),
  ),
  caption: [
    Giá trị Shapley cục bộ tại 4 điểm dữ liệu được chọn cho trò chơi giải thích sai số bình phương với mô hình *Random Forest* trên tập dữ liệu Bikeshare
  ],
) <table-bikeshare-squared-error-selected-rf>

Áp dụng mục *3.2* để tính Giá trị Shapley toàn cục cho từng cụm dữ liệu. @figure-bikeshare-squared-error-number-iterations-rf trình bày sự hội tụ của Giá trị Shapley toàn cục cho từng cụm theo số lần lặp $m$. Đáng chú ý, toàn bộ 12 cụm dữ liệu đều có Giá trị Shapley âm, tức là mọi cụm đều đóng góp làm giảm sai số bình phương. Trong đó, các cụm có Giá trị Shapley âm lớn nhất là $Q_(12)$ ($phi_(12) = -3816.853$), $Q_6$ ($phi_6 = -3734.777$) và $Q_5$ ($phi_5 = -3503.750$), có thể giải thích rằng dữ liệu huấn luyện của những tháng này mang lại nhiều thông tin giúp mô hình dự đoán tốt hơn: $Q_5$, $Q_6$ là những tháng có nhu cầu thuê xe cao, riêng $Q_(12)$ (tháng 12) tuy là tháng mùa đông nhưng vẫn có mức đóng góp lớn nhất, cho thấy mức đóng góp của cụm dữ liệu không chỉ phụ thuộc vào nhu cầu thuê xe theo mùa. Ngược lại, cụm $Q_3$ có Giá trị Shapley âm nhỏ nhất ($phi_3 = -1386.153$). Giá trị cụ thể của từng cụm dữ liệu được trình bày trong @table-bikeshare-squared-error-phi-global-rf.

#figure(
  image("figures/bikeshare_12_squared_error_number_iterations.png"),
  caption: [Sự hội tụ của Giá trị Shapley toàn cục của từng cụm dữ liệu theo số lần lặp $m$ từ 1 đến $M = 150$ cho trò chơi sai số bình phương trên tập dữ liệu Bikeshare với mô hình *Random Forest*],
) <figure-bikeshare-squared-error-number-iterations-rf>

#figure(
  table(
    columns: 2,
    align: (left, right),
    [*Cụm dữ liệu $Q_k$*], [*Giá trị Shapley $phi_k$*],

    ..csv("results/bikeshare_06_squared_error_phi_global.csv")
      .slice(1)
      .map(row => ([$Q_#int(row.first().slice(8))$], round_3(float(row.at(1)))))
      .flatten(),
  ),
  caption: [Giá trị Shapley toàn cục của từng cụm dữ liệu cho trò chơi giải thích sai số bình phương với mô hình *Random Forest* trên tập dữ liệu Bikeshare tại lần lặp cuối $M = 150$],
) <table-bikeshare-squared-error-phi-global-rf>

Để minh chứng tính độc lập với mô hình (model agnostic), chúng ta lặp lại thí nghiệm giải thích sai số bình phương ở trên với mô hình *KNN-10*. Toàn bộ cấu hình: dữ liệu huấn luyện, cách phân cụm, và số lần lặp tối đa $M = 150$ được giữ nguyên. @figure-bikeshare-squared-error-selected-knn10 thể hiện Giá trị Shapley của từng cụm dữ liệu huấn luyện đối với sai số bình phương của mô hình *KNN-10* cho cùng 4 điểm dữ liệu được chọn. Tương tự như với mô hình *Random Forest*, tại mỗi điểm dữ liệu, các cụm dữ liệu lân cận về thời gian có xu hướng đóng góp làm giảm sai số bình phương, trong khi một số cụm ở xa có thể đóng góp làm tăng sai số. Giá trị cụ thể của từng điểm dữ liệu được trình bày trong @table-bikeshare-squared-error-selected-knn10.

#figure(
  image("figures/bikeshare_19_squared_error_selected_knn10.png"),
  caption: [Giải thích sai số bình phương cho các điểm dữ liệu $t = 50, 650, 1450, 2250$ bằng Giá trị Shapley cho độ quan trọng của cụm dữ liệu với mô hình *KNN-10* trên tập dữ liệu Bikeshare],
) <figure-bikeshare-squared-error-selected-knn10>

#figure(
  table(
    columns: 5,
    align: (left, center, center, center, center),
    [*Cụm dữ liệu $Q_k$*], [*$t = 50$*], [*$t = 650$*], [*$t = 1450$*], [*$t = 2250$*],

    ..range(1, 13)
      .map(k => (
        [$Q_#k$],
        ..csv("results/bikeshare_19_squared_error_phi_selected_knn10.csv")
          .slice(1)
          .filter(row => int(row.first()) in (50, 650, 1450, 2250))
          .map(row => round_3(float(row.at(k)))),
      ))
      .flatten(),
  ),
  caption: [
    Giá trị Shapley cục bộ tại 4 điểm dữ liệu được chọn cho trò chơi giải thích sai số bình phương với mô hình *KNN-10* trên tập dữ liệu Bikeshare
  ],
) <table-bikeshare-squared-error-selected-knn10>

Áp dụng mục *3.2* để tính Giá trị Shapley toàn cục cho từng cụm dữ liệu cho trò chơi sai số bình phương với mô hình *KNN-10*. @figure-bikeshare-squared-error-number-iterations-knn10 trình bày sự hội tụ của Giá trị Shapley toàn cục cho từng cụm theo số lần lặp $m$. Tương tự như với mô hình *Random Forest*, toàn bộ 12 cụm dữ liệu đều có Giá trị Shapley âm, tức là mọi cụm đều đóng góp làm giảm sai số bình phương. Trong đó, các cụm có Giá trị Shapley âm mạnh nhất là $Q_(10)$ ($phi_(10) = -3280.943$), $Q_8$ ($phi_8 = -3143.653$) và $Q_2$ ($phi_2 = -3030.729$). Ngược lại, cụm $Q_3$ có Giá trị Shapley âm yếu nhất ($phi_3 = -1811.782$). Giá trị cụ thể của từng cụm dữ liệu được trình bày trong @table-bikeshare-squared-error-phi-global-knn10.

#figure(
  image("figures/bikeshare_18_squared_error_number_iterations_knn10.png"),
  caption: [Sự hội tụ của Giá trị Shapley toàn cục của từng cụm dữ liệu theo số lần lặp $m$ từ 1 đến $M = 150$ cho trò chơi sai số bình phương trên tập dữ liệu Bikeshare với mô hình *KNN-10*],
) <figure-bikeshare-squared-error-number-iterations-knn10>

#figure(
  table(
    columns: 2,
    align: (left, right),
    [*Cụm dữ liệu $Q_k$*], [*Giá trị Shapley $phi_k$*],

    ..csv("results/bikeshare_18_squared_error_phi_global_knn10.csv")
      .slice(1)
      .map(row => ([$Q_#int(row.first().slice(8))$], round_3(float(row.at(1)))))
      .flatten(),
  ),
  caption: [Giá trị Shapley toàn cục của từng cụm dữ liệu cho trò chơi giải thích sai số bình phương với mô hình *KNN-10* trên tập dữ liệu Bikeshare tại lần lặp cuối $M = 150$],
) <table-bikeshare-squared-error-phi-global-knn10>

=== 4.2.3. Chiến lược thu thập dữ liệu huấn luyện

Sau khi tính được Giá trị Shapley cho từng cụm dữ liệu, chúng ta đề xuất thêm một cách ứng dụng thực tế của phương pháp, cụ thể là sử dụng Giá trị Shapley đã tính được để đề xuất chiến lược thu thập lại dữ liệu huấn luyện để huấn luyện mô hình nhằm mục đích cải thiện độ chính xác dự đoán.

Mục tiêu của việc này là xây dựng một tập dữ liệu huấn luyện $cal(D)^"train"$ mới sao cho độ chính xác dự đoán của mô hình sau khi được huấn luyện trên tập dữ liệu $cal(D)^"train"$ sẽ cho kết quả tốt hơn khi kiểm thử trên tập $cal(D)^"eval"$ không trùng với tập $cal(D)^"train"$. Chúng ta cố định kích thước $cal(D)^"train"$, cho mọi chiến lược. Điều này có nghĩa là chúng ta chỉ có thể cân đối từng cụm dữ liệu: nếu muốn đưa thêm dữ liệu của một cụm vào, chúng ta phải bớt đi một lượng dữ liệu tương ứng ở cụm khác. Với yêu cầu này, chúng ta có thể sử dụng nhiều chiến lược thu thập dữ liệu khác nhau. Ở đây chúng ta đề xuất 2 chiến lược, trong đó chiến lược *tối đa (max)* là chiến lược đề xuất dựa trên Giá trị Shapley, còn chiến lược *đều (equal)* được dùng làm cơ sở so sánh:

- Chiến lược *đều*: lấy ngẫu nhiên một số lượng điểm dữ liệu bằng nhau từ mỗi cụm dữ liệu,
- Chiến lược *tối đa*: lấy ngẫu nhiên điểm dữ liệu từ nhiều cụm khác nhau, với số lượng giữa các cụm được xác định bởi Giá trị Shapley toàn cục cho độ quan trọng của cụm dữ liệu đối với sai số bình phương. Cụ thể, những cụm có Giá trị Shapley nhỏ hơn, đóng góp mạnh hơn vào việc làm giảm sai số sẽ được lấy nhiều điểm dữ liệu hơn.

Cụ thể, chúng ta cài đặt cả 2 chiến lược đều sinh ra tập huấn luyện chứa $N^"strategy" = 4800$ điểm dữ liệu, tương ứng với $N^"strategy" \/ K = 400$ điểm mỗi cụm nếu chia đều với $K = 12$. Các điểm dữ liệu được lấy ngẫu nhiên sau khi đã loại bỏ tập đánh giá $cal(D)^"eval"$, nhằm đảm bảo tập kiểm thử và tập huấn luyện không trùng nhau.

Để thực hiện chiến lược *tối đa*, chúng ta sẽ tái sử dụng Giá trị Shapley toàn cục của trò chơi giải thích sai số bình phương với mô hình *Random Forest* đã tính ở @table-bikeshare-squared-error-phi-global-rf.
Chúng ta sẽ tính trọng số $w_k$ cho từng cụm theo Giá trị Shapley, sau đó sẽ tính số lượng điểm dữ liệu cần lấy từ từng cụm $N_k$ dựa trên công thức Softmax:

$
  N_k = N^"strategy" w_k / (sum_(j=1)^K w_j)
$ <math-bikeshare-strategy-max>

@math-bikeshare-strategy-max đảm bảo tổng số điểm dữ liệu được lấy từ tất cả các cụm bằng đúng $N^"strategy"$.

Để tính trọng số $w_k$, chúng ta sử dụng công thức sau:

$
  w_k = upright(e)^(-frac(phi_k, tau)), quad tau = 4 dot sigma_(phi)
$ <math-bikeshare-weight-strategy-max>

Trong đó $tau$ là nhiệt độ (temperature) thường được dùng với Softmax, được tính dựa trên độ lệch chuẩn $sigma_(phi)$ của toàn bộ Giá trị Shapley toàn cục. Lý do chọn $4 dot sigma_(phi)$ là vì dựa trên thí nghiệm để việc phân bổ dữ liệu giữa các cụm không quá lệch nhau, tránh trường hợp một cụm có Giá trị Shapley quá lớn sẽ chiếm gần như toàn bộ dữ liệu huấn luyện, dẫn đến việc mô hình không học được gì từ các cụm còn lại. Giá trị Shapley càng nhỏ, tức là đóng góp càng mạnh vào việc làm giảm sai số MSE, thì trọng số $w_k$ phải càng lớn, và do đó số lượng điểm dữ liệu được lấy từ cụm đó càng nhiều.

@table-bikeshare-squared-error-strategy-max-allocation thể hiện Giá trị Shapley toàn cục $phi_k$ và số lượng điểm dữ liệu được phân bổ cho từng cụm sau khi tính bằng @math-bikeshare-strategy-max. Chúng ta thấy rằng các cụm có Giá trị Shapley nhỏ, ví dụ cụm 12 với $phi_(12) = -3816.853$ và cụm 6 với $phi_6 = -3734.777$, được phân bổ nhiều điểm dữ liệu hơn, $N_(12) = 549, N_6 = 536$. Trong khi các cụm có Giá trị Shapley lớn hơn, cụm 3 với $phi_3 = -1386.153$ và cụm 2 với $phi_2 = -1517.504$, được phân bổ ít điểm dữ liệu hơn, $N_3 = 270, N_2 = 281$. Tuy nhiên sự chênh lệch giữa các cụm không quá lớn nhờ vào việc chọn nhiệt độ $tau$ phù hợp.

#figure(
  table(
    columns: 3,
    align: (left, right, right),
    [*Cụm dữ liệu $Q_k$*], [*Giá trị Shapley $phi_k$*], [*Phân bổ $N_k$*],

    ..csv("results/bikeshare_11_squared_error_strategy_allocation.csv")
      .slice(1)
      .map(row => ([$Q_#int(row.first().slice(8))$], round_3(float(row.at(1))), round_3(float(row.at(5)))))
      .flatten(),
  ),
  caption: [Giá trị Shapley toàn cục và số lượng điểm dữ liệu được phân bổ cho từng cụm với chiến lược *tối đa*, trò chơi giải thích sai số bình phương, mô hình *Random Forest*, tập dữ liệu Bikeshare],
) <table-bikeshare-squared-error-strategy-max-allocation>

Cuối cùng, chúng ta huấn luyện 2 mô hình trên 2 tập dữ liệu tương ứng với 2 chiến lược và đánh giá trên tập $cal(D)^"eval"$ bằng MSE cho từng cụm, và toàn bộ tập đánh giá:

$
  "MSE"_k = 1/(|cal(D)^"eval" inter cal(Q)_k|) sum_(x_t in cal(D)^"eval" inter cal(Q)_k) (y_t - f(x_t))^2
$ <math-bikeshare-mse-per-cluster>

$
  "MSE" = 1/(|cal(D)^"eval"|) sum_(k=1)^K sum_(x_t in cal(D)^"eval" inter cal(Q)_k) (y_t - f(x_t))^2
$

trong đó $|cal(D)^"eval" inter cal(Q)_k| = 30$ là số điểm đánh giá của cụm $k$, và $|cal(D)^"eval"| = 360$ là tổng số điểm của tập đánh giá.

@table-bikeshare-strategy-mse-global trình bày kết quả MSE toàn bộ tập đánh giá cho cả 2 chiến lược. Kết quả cho thấy có sự cải thiện: MSE toàn cục của chiến lược tối đa là 8845.389 thấp hơn so với chiến lược đều là 8894.368. @table-bikeshare-strategy-mse-per-cluster thì trình bày kết quả MSE theo từng cụm dữ liệu $Q_k$. Kết quả cho thấy chiến lược tối đa tốt hơn chiến lược đều ở 5 trên 12 cụm dữ liệu, bao gồm $Q_5$, $Q_6$, $Q_7$, $Q_8$ và $Q_(12)$. Trong đó đáng chú ý là cụm $Q_6$ giảm mạnh từ 22662.900 xuống 20720.315, và cụm $Q_8$ giảm từ 16141.455 xuống 15240.652. Ở các cụm còn lại, chiến lược tối đa cho kết quả kém hơn chiến lược đều, chẳng hạn cụm $Q_1$ tăng từ 3669.444 lên 4136.906 và cụm $Q_(10)$ tăng từ 9870.172 lên 10572.240, có thể giải thích do các cụm này được phân bổ ít điểm dữ liệu (lần lượt $N_1 = 315$ và $N_(10) = 324$) nên dự đoán không còn chính xác. Mặc dù không tốt hơn toàn bộ các cụm, mức giảm mạnh tại các cụm được ưu tiên dữ liệu giúp MSE toàn cục của chiến lược tối đa vẫn thấp hơn chiến lược đều. @figure-bikeshare-strategy-mse-per-cluster-rf minh hoạ lại @table-bikeshare-strategy-mse-per-cluster theo biểu đồ. Trong đó màu tím nét liền thể hiện chiến lược đều, màu xanh nét đứt thể hiện chiến lược tối đa.

#figure(
  table(
    columns: (auto, auto),
    align: (left, right),
    [*MSE chiến lược đều*], [*MSE chiến lược tối đa*],

    ..{
      let values = csv("results/bikeshare_09_squared_error_mse_global.csv")
        .slice(1)
        .map(row => round_3(float(row.at(1))))
      (values.at(0), values.at(1))
    },
  ),
  caption: [MSE toàn cục trên tập đánh giá $cal(D)^"eval"$ của 2 chiến lược *đều* (equal) và *tối đa* (max) với trò chơi giải thích sai số bình phương, mô hình *Random Forest*],
) <table-bikeshare-strategy-mse-global>

#figure(
  table(
    columns: (auto, auto, auto),
    align: (center, right, right),
    [*Cụm dữ liệu $Q_k$*], [*MSE chiến lược đều*], [*MSE chiến lược tối đa*],

    ..{
      csv("results/bikeshare_10_squared_error_mse_per_cluster.csv")
        .slice(1)
        .map(row => ([$Q_#int(row.first())$], round_3(float(row.at(1))), round_3(float(row.at(2)))))
        .flatten()
    },
  ),
  caption: [MSE theo từng cụm trên tập đánh giá $cal(D)^"eval"$ của 2 chiến lược *đều* và *tối đa* với trò chơi giải thích sai số bình phương, mô hình *Random Forest*],
) <table-bikeshare-strategy-mse-per-cluster>

#figure(
  image("figures/bikeshare_14_squared_error_strategy_mse.png"),
  caption: [MSE theo từng tháng trên tập đánh giá $cal(D)^"eval"$ của 2 chiến lược *đều* và *tối đa* với mô hình *Random Forest*, trò chơi giải thích sai số bình phương],
) <figure-bikeshare-strategy-mse-per-cluster-rf>

Dựa vào kết quả thu thập được, chúng ta có thể nhận xét chiến lược thu thập dữ liệu huấn luyện dựa trên Giá trị Shapley đối với dữ liệu Bikeshare cho thấy sự cải thiện so với chiến lược cơ sở là phân bổ *đều*. Cho thấy sự hợp lý của giả thuyết rằng đối với các cụm dữ liệu đóng góp lớn trong việc làm giảm sai số, thì việc thu thập thêm dữ liệu từ các cụm này sẽ giúp mô hình học tốt hơn và cải thiện độ chính xác và làm giảm sai số dự đoán.

#pagebreak()

= Chương 5. KẾT LUẬN VÀ KIẾN NGHỊ

== 5.1. Kết luận

Như đã trình bày ở những mục trước, nghiên cứu này đã thể hiện và minh hoạ một hướng tiếp cận mới trong lĩnh vực XAI, dùng để tính Giá trị Shapley cho các cụm dữ liệu huấn luyện. Điểm khác biệt nằm ở chỗ nghiên cứu này sử dụng giá trị $y$ là kết quả thực tế thay vì chỉ sử dụng dự đoán $f(x)$. Nghiên cứu thay câu hỏi "từng cụm dữ liệu đóng góp bao nhiêu vào dự đoán $f(x)$" bằng câu hỏi mới "từng cụm dữ liệu đóng góp bao nhiêu làm giảm sai số bình phương $(y - f(x))^2$, và trung bình trên tập dữ liệu là MSE". Phương pháp này còn có tính chất độc lập với mô hình (model-agnostic), không thay đổi cấu hình, tham số của mô hình ban đầu.

Về mặt lý thuyết, nghiên cứu được phát triển dựa trên 2 nghiên cứu là Giá trị Shapley thể hiện độ quan trọng của đặc trưng (feature) @lundberg2017unifiedapproachinterpretingmodel và Giá trị Shapley thể hiện độ quan trọng của từng cụm dữ liệu (cluster) trong dự đoán $f(x)$ @Brandsaeter2022. Đóng góp của nghiên cứu này thể hiện ở việc không chỉ dựa trên dự đoán mà còn trong bối cảnh giá trị thực tế đã biết được trình bày ở mục *3.1* nhờ vào sử dụng MSE. Nghiên cứu cũng đưa ra công thức hàm phần thưởng dựa trên MSE ở @math-shapley-value-hindsight-reward-2, công thức xấp xỉ Giá trị Shapley cục bộ ở @math-shapley-value-hindsight-local kèm @algorithm-shapley-value-hindsight để có thể tính được xấp xỉ Giá trị Shapley trong thời gian có hạn với chi phí tính toán được kiểm soát qua số lần lặp $M$, Giá trị Shapley toàn cục được tính bởi @math-shapley-value-hindsight-global. Cuối cùng là đề xuất mở rộng cho bài toán phân loại ở mục *3.3* bằng cách thay hàm phần thưởng bằng mô hình *AAKR* trong @math-shapley-value-hindsight-classification.

Kết quả thực nghiệm trên dữ liệu tạo sinh ở mục *4.1* thể hiện tính đúng đắn của phương pháp. Bởi vì tập huấn luyện và tập kiểm thử là tương đối giống nhau, chúng ta đặt giả thuyết điểm dữ liệu nằm ở cụm nào thì cụm dữ liệu đó đóng góp lớn nhất vào việc làm giảm MSE, và kết quả kiểm chứng cho thấy Giá trị Shapley của các cụm dữ liệu tương ứng với từng điểm dữ liệu kiểm thử đều phản ánh chính xác điều này.

Đối với kết quả thực nghiệm trên dữ liệu thực tế Bikeshare ở mục *4.2*, nghiên cứu đã cho thấy được tính khả thi của phương pháp, khi mà toàn bộ 12 cụm dữ liệu đều đóng góp làm giảm MSE, trong đó các cụm dữ liệu mùa hè như $Q_5$, $Q_6$, $Q_9$ có mức đóng góp lớn, phù hợp với giả thuyết rằng nhu cầu thuê xe đạp công cộng có tính thay đổi theo mùa; riêng cụm $Q_(12)$ (tháng 12) tuy thuộc mùa đông nhưng có mức đóng góp lớn nhất, cho thấy mức đóng góp của cụm dữ liệu không chỉ phụ thuộc vào mùa.

Bên cạnh đó nghiên cứu cũng đề xuất một chiến lược thu thập dữ liệu huấn luyện mới dựa trên Giá trị Shapley toàn cục cho từng cụm dữ liệu đã được tính trước gọi là chiến lược *tối đa*. Chiến lược này xây dựng trên giả thuyết rằng nếu chúng ta biết cụm nào đóng góp nhiều vào việc làm giảm sai số MSE thì chúng ta sẽ đưa thêm nhiều điểm dữ liệu thuộc cụm dữ liệu vào tập dữ liệu huấn luyện, và ngược lại đối với cụm dữ liệu nào làm tăng MSE, thì chúng ta sẽ lấy bớt điểm dữ liệu thuộc cụm đó ra khỏi tập dữ liệu huấn luyện. Thử nghiệm trên tập dữ liệu Bikeshare ở mục *4.2.3*, chiến lược *tối đa* đạt MSE thấp hơn chiến lược *đều*. Kết quả này thể hiện tính khả thi của chiến lược trong việc cải thiện độ chính xác dự đoán của mô hình.

== 5.2. Kiến nghị

Từ các kết quả đạt được, chúng ta có thể đề xuất một vài hướng có thể nghiên cứu tiếp tục trong tương lai:

- *Mở rộng hàm phần thưởng:* Nghiên cứu này sử dụng MSE cùng giá trị thực tế $y$ biết trước để tính Giá trị Shapley, các nghiên cứu tiếp theo có thể sử dụng các hàm lỗi khác MSE như MAE, Huber loss, ... [TODO more] thường được dùng trong các bài toán hồi quy (Regression). Đối với bài toán phân loại, có thể thay mô hình *AAKR* bằng các mô hình khác [TODO more] có cùng chức năng dự đoán.
- *Thử nghiệm với nhiều mô hình khác:* Nghiên cứu này chỉ sử dụng mô hình *Random Forest*, *KNN-10* cho việc huấn luyện dữ liệu. Có thể thử nghiệm trên một vài mô hình khác như mô hình có kiến trúc học sâu (Deep Learning) [TODO more].
- *Tích hợp vào quy trình:* Đưa nghiên cứu này trở thành một phương pháp được chuẩn hoá, để khi gặp sự cố trong lúc vận hành một bài toán trong thực tế, có thể tự động hoá đánh giá biến cố này xảy ra đến từ nguyên nhân nào trong việc huấn luyện dữ liệu. Điều này hỗ trợ việc điều phối tỷ trọng dữ liệu huấn luyện trong các quy trình tái huấn luyện liên tục (continuous retraining), hướng đến các hệ thống AI tự hiệu chỉnh cho các lĩnh vực đòi hỏi độ tin cậy và an toàn cao.

#pagebreak()

= DANH MỤC TÀI LIỆU THAM KHẢO

#bibliography(
  "refs.bib",
  title: none,
)
