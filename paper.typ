#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, shapes
#import "@preview/lovelace:0.3.1": *

#set text(lang: "vi")
#set text(font: "New Computer Modern")
#set text(size: 11pt)

#set page(numbering: "1")
#set math.equation(numbering: "(1)")

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
  [AAKR], [Auto-Associative Kernel Regression], [Phân loại bất thường],
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

Đa phần các mô hình AI hiệu quả hiện nay đều có kiến trúc rất phức tạp với hàng triệu tham số. Với giá trị đầu vào đưa vào mô hình AI, không dễ gì dự đoán được kết quả đầu ra, việc giải thích tại sao thậm chí còn khó hơn. Vì vậy các mô hình AI này còn được gọi là các hộp đen (black box), chúng ta hoàn toàn không thể biết chính xác bên trong mô hình hoạt động cụ thể như thế nào. Tuy nhiên, bản chất hộp đen này khiến việc đặt niềm tin và triển khai AI trong các hệ thống đòi hỏi tính an toàn cao (safety critical systems) gặp nhiều khó khăn. Các phương pháp XAI ra đời nhằm cố gắng giải thích kết quả đầu ra của mô hình AI, củng cố niềm tin cho người dùng mô hình cũng như giúp cho nhà phát triển mô hình có thể cải thiện được kết quả tốt hơn.

Nghiên cứu này tập trung vào một cách tiếp cận mới trong XAI đó là giải thích *sai số của dự đoán* thay vì giải thích dự đoán. Trong thực tế khi có một vấn đề hay một sự cố xảy ra, ví dụ như sai sót khi mô hình dự đoán sai, thì chúng ta mới sử dụng phương pháp XAI để kiểm tra lại tại sao dự đoán sai thực tế. Đối với các phương pháp XAI vốn chỉ tập trung giải thích giá trị dự đoán mà không biết trước kết quả giá trị thực tế, thì kết quả giải thích sẽ chỉ phản ánh được tại sao đưa ra dự đoán chứ không thể giải thích được tại sao lại đưa ra dự đoán lỗi. Nghiên cứu này sẽ trình bày phương pháp XAI sử dụng giá trị thực tế đã được biết, xây dựng dựa trên phương pháp XAI giải thích dự đoán dựa trên mức độ đóng góp của từng cụm dữ liệu huấn luyện (data training cluster) thông qua Lý thuyết trò chơi liên minh Giá trị Shapley (Coalitional Game Theory Shapley values)

== 1.2. Lý do lựa chọn đề tài

Lý do lựa chọn đề tài xuất phát từ 3 nội dung chính sau:

- *Khoảng trống nghiên cứu về phương pháp XAI giải thích cục bộ (local) cho sai số của dự đoán*: Sự phát triển của mô hình AI đi kèm với sự phát triển các phương pháp XAI giải thích cục bộ như LIME [TODO], ICE [TODO], PredDiff [TODO]. Tuy nhiên điểm chung của các phương pháp này là đều giải thích giá trị dự đoán khi chưa biết trước kết quả thực tế. Bên cạnh đó các phương pháp XAI giải thích cho sai số dự đoán hầu hết đều mang tính toàn cục (global), thể hiện dự đoán trên toàn bộ tập dữ liệu, chứ không dự đoán cho từng điểm dữ liệu riêng biệt. Cho nên hiện tại chưa có một phương pháp XAI nào giải thích cục bộ cho sai số dự đoán dựa trên tập dữ liệu mà không phụ thuộc vào mô hình (model agnostic).
- *Tiếp cận hướng dữ liệu:*: Nhiều phương pháp XAI tập trung vào đo lường mức độ quan trọng của các đặc trưng (feature) trong dự đoán, nhưng lại bỏ qua tầm quan trọng của tập dữ liệu huấn luyện. Trong thực tế, tập dữ liệu huấn luyện có thể đóng vai trò quyết định đến kết quả dự đoán của mô hình. Nếu tập dữ liệu huấn luyện bị thiên lệch (bias) thì kết quả đầu ra của mô hình cũng sẽ bị thiên lệch theo. Một ví dụ tương tự có thể thấy trong môn bóng rổ: Chiều cao là một đặc trưng rất quan trọng ảnh hưởng đến hiệu suất thi đấu bóng rổ. Tuy nhiên, nếu xét riêng trong giải đấu NBA chuyên nghiệp, nơi mà hầu hết các vận động viên đều đã sở hữu chiều cao vượt trội so với người bình thường, thì chiều cao lại không còn là yếu tố quan trọng có thể giải thích được sự chênh lệch về hiệu suất giữa các cầu thủ nữa. Điều này cho thấy vai trò của một đặc trưng có được coi là *quan trọng* hay không phụ thuộc hoàn toàn vào tập dữ liệu huấn luyện mà mô hình được học. Do đó, việc giải thích mô hình dưới góc nhìn hướng dữ liệu, cụ thể trong nghiên cứu này là đánh giá ảnh hưởng của từng cụm dữ liệu huấn luyện, là cần thiết để hiểu rõ bản chất và cải thiện độ chính xác dự đoán.
- *Nhu cầu thực tiễn trong phân tích sự cố*: Ở các hệ thống đòi hỏi tính an toàn cao, thách thức lớn nhất luôn nằm ở việc liệu các dự đoán của mô hình AI có thực sự chính xác và đáng tin cậy hay không. Câu hỏi tại sao mô hình đưa ra dự đoán như thế này không quan trọng bằng câu hỏi tại sao mô hình lại dự đoán lệch thực tế sau khi có mô hình AI dự báo say dẫn đến sự cố nghiêm trọng. Hiểu được điều này sẽ giúp các nhà phát triển mô hình sửa chữa, cập nhật mô hình tốt hơn và phòng ngừa các dự đoán sai lệch dẫn đến sự cố trong tương lai.

== 1.3. Câu hỏi nghiên cứu

Nhằm giải quyết khoảng trống nghiên cứu về giải thích sai số dự đoán cục bộ, đề tài tập trung vào việc trả lời các câu hỏi nghiên cứu sau:

- Làm thế nào để ứng dụng Giá trị Shapley từ Lý thuyết trò chơi liên minh nhằm xác định ảnh hưởng cục bộ của các cụm dữ liệu huấn luyện đến sai số dự đoán và độ chính xác phân loại trong bối cảnh giá trị thực tế đã biết?
- Các đặc tính lý thuyết của Giá trị Shapley thể hiện như thế nào trong bài toán giải thích sai số dự đoán cục bộ?
- Việc sử dụng kết quả giải thích có giúp xây dựng chiến lược thu thập dữ liệu huấn luyện mới nhằm cải thiện độ chính xác dự đoán của mô hình hay không?

== 1.4. Mục đích nghiên cứu

*Mục đích tổng quát:* Xây dựng phương pháp XAI mới nhằm giải thích cục bộ cho sai số dự đoán trong bối cảnh giá trị thực tế đã biết, không phụ thuộc vào mô hình, tập trung vào dữ liệu thay vì đặc trưng, để cuối cùng có thể tối ưu hóa cụm dữ liệu huấn luyện cho các mô hình AI.

Để đạt được mục đích trên, đề tài đề ra các mục tiêu cụ thể sau:

- *Về mặt lý thuyết:* Đề xuất phương pháp tính Giá trị Shapley cho các cụm dữ liệu huấn luyện để đánh giá sự đóng góp của từng cụm dữ liệu huấn luyện đến sai số dự đoán cục bộ trong bài toán hồi quy và bài toán phân loại. Đồng thời chứng minh các tính chất của Giá trị Shapley vẫn còn đúng đối với phương pháp này.
- *Về mặt ứng dụng:* Thử nghiệm phương pháp mới trên dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng, từ đó đề xuất chiến lược thu thập dữ liệu huấn luyện để tối ưu độ sai sót dự đoán của mô hình AI.

Phương pháp này mới là vì chưa có công trình nghiên cứu nào giải thích sai số trong dự đoán cục bộ, và cũng không nhiều công trình tiếp cận theo hướng dữ liệu cụ thể là nghiên cứu tập dữ liệu huấn luyện thay cho hướng nghiên cứu dựa trên đặc trưng vốn đã được nghiên cứu rộng rãi.

== 1.5. Đối tượng và Phạm vi nghiên cứu

Đối tượng nghiên cứu chính: Phương pháp XAI độc lập với mô hình dựa trên Lý thuyết trò chơi liên minh với Giá trị Shapley. Trong đó bao gồm mức độ đóng góp của các cụm dữ liệu huấn luyện đối với sai số dự đoán cục bộ, cụ thể là MSE trong bài toán hồi quy tuyến tính (Linear Regression) và độ chính xác (Accuracy) trong bài toán phân loại (Classification), với bối cảnh là biết trước giá trị thực tế.

Phạm vi nghiên cứu: Nghiên cứu tập trung vào giải thích độ đóng góp của cụm dữ liệu huấn luyện trong bài toán:

- Hồi quy tuyến tính với sai số MSE sử dụng mô hình AI Random Forest và KNN.
- Phân loại với độ chính xác Accuracy và mô hình AI AAKR.

Tập dữ liệu thực nghiệm bao gồm:

- Dữ liệu tạo sinh (synthetic data) để kiểm chứng tính đúng đắn về mặt toán học của phương pháp.
- Dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng tại thành phố [TODO].

Giới hạn của nghiên cứu:

- Nghiên cứu không đề xuất cách phân cụm mới cho tập dữ liệu huấn luyện, mà sử dụng các phương pháp phân cụm tự nhiên hoặc có sẵn của dữ liệu
- Nghiên cứu không đề xuất công thức đánh giá sai số dự đoán mới mà sử dụng lại sai số có sẵn như MSE.

== 1.6. Phương pháp nghiên cứu

- *Về mặt lý thuyết*: Nghiên cứu sử dụng Lý thuyết trò chơi liên minh với Giá trị Shapley để định nghĩa mô hình trò chơi cho cụm dữ liệu huấn luyện. Bao gồm các tính chất của Giá trị Shapley, đề xuất và chứng minh các công thức liên quan. Đồng thời giải thích ý nghĩa Giá trị Shapley cho từng cụm dữ liệu huấn luyện trong bối cảnh giải thích sai số dự đoán cục bộ.
- *Về mặt ứng dụng*: Nghiên cứu sử dụng dữ liệu thực nghiệm, để kiểm chứng tính đúng đắn phương pháp, đồng thời đánh giá hiệu quả của phương pháp trong việc giải thích sai số dự đoán cục bộ. Dữ liệu thực nghiệm bao gồm dữ liệu tạo sinh và dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng. Các mô hình AI được sử dụng bao gồm Random Forest, KNN và AAKR.

== 1.7. Ý nghĩa khoa học và thực tiễn

- *Ý nghĩa khoa học:* Đề xuất phương pháp XAI mới giải thích sai số dự đoán cục bộ, độc lập với mô hình, tập trung vào dữ liệu thay vì đặc trưng nhờ vào Lý thuyết trò chơi liên minh và Giá trị Shapley. Phương pháp này có thể được áp dụng cho nhiều mô hình AI khác nhau, không bị giới hạn bởi một mô hình cụ thể. Đồng thời nghiên cứu cung cấp một góc nhìn mới về tư duy theo hướng dữ liệu, cụ thể là về cách giải thích đóng góp của từng cụm dữ liệu huấn luyện đối với sai số dự đoán, từ đó giúp các nhà nghiên cứu và phát triển mô hình AI hiểu rõ hơn về cách dữ liệu huấn luyện ảnh hưởng đến kết quả dự đoán.
- *Ý nghĩa thực tiễn:* Phương pháp này có thể giúp các nhà phát triển mô hình AI xác định cụm dữ liệu huấn luyện nào là quan trọng, từ đó tối ưu hóa tập dữ liệu huấn luyện để cải thiện độ chính xác dự đoán của mô hình. Ngoài ra, việc giải thích sai số dự đoán cục bộ sau khi vận hành thực tế hoặc khi có sự cố xảy ra sẽ giúp các nhà phát triển mô hình AI phát hiện và khắc phục các vấn đề trong dữ liệu huấn luyện, từ đó nâng cao độ tin cậy và hiệu quả của các hệ thống AI trong các ứng dụng thực tiễn có tính rủi ro cao.

#pagebreak()

= Chương 2. TỔNG QUAN

// TỔNG QUAN về vấn đề nghiên cứu: phân tích, đánh giá các công trình nghiên cứu liên quan trực tiếp đến đề tài luận văn đã được công bố ở trong và ngoài nước, chỉ ra những vấn đề mà luận văn sẽ tập trung giải quyết, xác định mục tiêu của đề tài, nội dung và phương pháp nghiên cứu;

== 2.1. Các công trình nghiên cứu liên quan

XAI được sinh ra để cung cấp cho người dùng và nhà phát triển các công cụ để hiểu rõ hơn về cách mà mô hình AI đưa ra dự đoán. Ví dụ như một mô hình AI quyết định cho vay tín dụng thì kết quả chỉ có thể là quyết định cho vay hoặc không, nhưng khi khách hàng hỏi lại kỹ hơn tại sao lại từ chối yêu cầy vay vốn thì lúc đó cần phải giải thích rõ hơn ví dụ như khách hàng có lịch sử tín dụng xấu, hoặc vì một tiêu chuẩn nào đó khác. XAI còn được dùng để kiểm chứng mô hình có học được đúng các đặc trưng như nhà phát triển mong muốn hay không. Ví dụ với một mô hình AI phân loại loài gấu, giữa gấu bắc cực và gấu nâu, có khả năng mô hình học đặc trưng màu sắc của tuyết để phân biệt thay vì học đặc trưng về màu sắc hay hình dáng cơ thể của 2 loài gấu.

#figure(
  table(
    columns: (auto, auto, auto),
    stroke: 0.5pt,
    align: left,
    [*Toàn cục hay cục bộ*], [*Hướng đặc trưng hay dữ liệu*], [*Phương pháp*],

    table.cell(rowspan: 2)[*Toàn cục*],
    [Đặc trưng],
    [SAGE [TODO] \
      Permutation feature importance [TODO] \
      ALEPlots [TODO]
    ],

    [Dữ liệu],
    [Data Banzhaf [TODO] \
      Cook’s distance [TODO]
    ],

    table.cell(rowspan: 2)[*Cục bộ*],
    [Đặc trưng],
    [Marginal Shapley values [TODO] \
      Conditional Shapley values [TODO] \
      PredDiff [TODO] \
      Anchors [TODO] \
      Counterfactual explanations [TODO] \
      LIME [TODO] \
      ICE [TODO]
    ],

    [Dữ liệu],
    [Influence functions for perturbing training data [TODO] \
      Case-based explanations [TODO] \
      Shapley values for cluster importance [TODO]
    ],
  ),
  caption: [Phân loại các phương pháp XAI theo phạm vi và đối tượng giải thích],
  placement: none,
) <table-overview>

@table-overview tổng hợp các phương pháp XAI được phân loại theo 2 tiêu chí: phạm vi giải thích (toàn cục hay cục bộ) và đối tượng giải thích (đặc trưng hay dữ liệu huấn luyện). Một số phương pháp XAI cung cấp giải thích toàn cục, nghĩa là giải thích toàn bộ mô hình AI, từng thành phần của mô hình đóng góp đến toàn bộ dự đoán như thế nào. Trong khi các phương pháp khác cung cấp giải thích cục bộ, nghĩa là giải thích từng dự đoán riêng lẻ một của mô hình tại từng thời điểm cụ thể. Một khác biệt quan trọng nữa giữa các phương pháp XAI là giải thích dựa trên đặc trưng hay là dữ liệu huấn luyện. Các phương pháp XAI toàn cục có thể chia làm 2 nhóm là phân tích ảnh hưởng của các đặc trưng khác nhau ví dụ như: *SAGE* [TODO], *Permutation feature importance* [TODO] và *ALEPlots* [TODO] hoặc đánh giá sử dụng dữ liệu huấn luyện ví dụ như: *Data Banzhaf* [TODO].

Bên cạnh hướng giải thích toàn cục là hướng cục bộ, để giải thích từng dự đoán đơn lẻ tại từng thời điểm cục bộ, ta cũng có thể chia thành 2 nhóm phương pháp XAI dựa trên mức độ quan trọng của đặc trưng hoặc dựa trên mức độ ảnh hưởng của cụm dữ liệu huấn luyện đến dự đoán. Nhóm thứ 1 có thể kể đến như Marginal Shapley values [TODO], Conditional Shapley values [TODO], PredDiff [TODO], Anchors [TODO], Counterfactual explanations [TODO], LIME [TODO] và ICE [TODO]. Nhóm thứ 2 có thể kể đến như Influence functions for perturbing training data [TODO], Case-based explanations [TODO] và Shapley values for cluster importance [TODO]. Nhóm thứ 1 chứa các phương pháp XAI phổ biến và được trích dẫn nhiều nhất trong các công trình nghiên cứu khác. Nhóm thứ 2, tập trung vào dữ liệu, thì lại ít phương pháp hơn. Có 3 phương pháp có thể kể đến là:

- *Influence functions for perturbing training data* [TODO] để khảo sát mức độ nhạy cảm của dự đoán đối với các nhiễu loạn nhỏ trong tập dữ liệu huấn luyện.
- *Case-based explanations* [TODO] mục đích là để dùng các ví dụ dự đoán trong quá khứ để kiểm tra và giải thích cho các ví dụ trong tương lai.
- *Shapley values for cluster importance* [TODO] là một cách tiếp cận đánh giá mức độ ảnh hưởng của từng cụm dữ liệu huấn luyện nhỏ trong tập dữ liệu huấn luyện đến dự đoán của mô hình AI.

Bài nghiên cứu này sẽ dựa trên phương pháp *Shapley values for cluster importance* [TODO] làm nền tảng để phát triển thành phương pháp XAI mới giải thích sai số dự đoán cục bộ, độc lập với mô hình, tập trung vào dữ liệu thay vì đặc trưng.

== 2.2. Giá trị Shapley trong Trò chơi liên minh

Giá trị Shapley được phát triển bởi [TODO] trong lĩnh vực Lý thuyết trò chơi liên minh để giải quyết bài toán chia lợi ích công bằng giữa các người chơi trong một trò chơi liên minh. Giả sử có một trò chơi với liên minh $N$ người chơi. Sau khi chơi xong, liên minh sẽ được nhận phần thường là $v(N)$. Lấy ví dụ trò chơi câu cá, người chơi là những người đi câu cá, và phần thưởng là số cá câu được.

Bài toàn đặt ra là làm thể nào để chia phần thưởng công bằng cho từng người chơi. Nếu toàn bộ người chơi cùng tham gia thì tổng phần thưởng là $v(N)$, nếu mỗi lần chơi chỉ có một tập con $S subset N$ người chơi tham gia, thì phần thưởng nhận được là $v(S)$. Ta định nghĩa hàm tính phần thưởng $v$ là một ánh xạ từ liên minh $S$ và ra phần thưởng là số thực $v : 2^(|N|) arrow.r RR$. Một người chơi $i$, có thể tham gia nhiều liên minh $S$ khác nhau. Dựa vào đóng góp của người chơi trong toàn bộ các liên minh mà tính ra được phần thưởng mà người chơi xứng đáng được nhận.

Có nhiều cách để tính phần thưởng cho người chơi, trong nội dung bài nghiên cứu này sẽ sử dụng Giá trị Shapley, công thức được tham khảo từ [TODO] như sau:

#figure(
  $
    phi_i = sum_(S subset.eq N backslash {i}) (|S|!(|N| - |S| - 1)!) / (|N|!) dot [v(S union {i}) - v(S)]
  $,
) <math-shapley-value-1>

@math-shapley-value-1 chính là giá trị trung bình toàn bộ phần chênh lệch giữa phần thưởng tất cả các liên minh có người chơi $i$ tham gia $S union {i})$ và phần thưởng tất cả các liên minh còn lại không có người chơi $i$. Với trò chơi câu cá, chúng ta so sánh toàn bộ số cá câu được khi có người chơi $i$ tham gia và không có người chơi $i$ tham gia trong toàn bộ liên minh có thể lập ra để tính ra phần thưởng của người chơi.

Từ công thức @math-shapley-value-1, có thể hiểu Giá trị Shapley của người chơi $i$ là trung bình giá trị đóng góp (marginal contribution) theo hoán vị tương ứnng của các liên minh. Do đó có thể viết lại công thức Giá trị Shapley tương đương như sau:

#figure(
  $
    phi_i = 1 / (|N|!) sum_(cal(O) in pi(|N|)) [v("Pre"^i (cal(O)) union {i}) - v("Pre"^i (cal(O)))]
  $,
) <math-shapley-value-2>

Trong đó:

- $pi(|N|)$ là tập hợp tất cả các hoán vị của $N$ người chơi.
- $"Pre"^i (cal(O))$ là tập hợp tất cả người chơi có vị trí ở trước người chơi $i$ khi sắp xếp trong hoán vị $cal(O) in pi(|N|)$.

Giá trị Shapley có 4 tính chất cơ bản sau:

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

cho mọi $i in N$. Bên cạnh đó, với mọi số thực $a$, ta cũng có

#figure(
  $
    phi_i(a v) = a phi_i(v)
  $,
) <math-shapley-value-linearity-2>

cho mọi $i in N$.

- *Người chơi zero* (Null player): Người chơi zero là người chơi có đóng góp bằng 0 $phi_i = v(zero.slashed)$, nghĩa là
$v({i}) = v(zero.slashed)$  và $v(S union i) = v(S)$ cho toàn bộ liên minh $S subset.eq N$. Thông thường ta ngầm hiểu rằng $v(zero.slashed) = 0$.

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

Để tính Giá trị Shapley, chúng ta cần tính toàn bộ phần chênh lệch đóng góp theo toàn bộ hoán vị có thể có cho từng người chơi. @demo-fish-2 tính cho người chơi $A$, @demo-fish-3 tính cho người chơi $B$ và nguời chơi $C$ vì $B$ và $C$ có Giá trị Shapley giống nhau.


#figure(
  table(
    columns: 6,
    align: (left, left, left, right, right, right),

    [*$cal(O)$*],
    [*$S union {k}$*],
    [*$S$*],
    [*$f_(cal(O) union {i})$*],
    [*$f_cal(O)$*],
    [*$f_(cal(O) union {k}) - f_cal(O)$*],

    [${A, B, C}$], [${A}$], [$emptyset$], [30], [0], [30],
    [${A, C, B}$], [${A}$], [$emptyset$], [30], [0], [30],
    [${B, A, C}$], [${A, B}$], [${B}$], [70], [20], [50],
    [${B, C, A}$], [${A, B, C}$], [${B, C}$], [100], [20], [80],
    [${C, A, B}$], [${A, C}$], [${C}$], [70], [20], [50],
    [${C, B, A}$], [${A, B, C}$], [${B, C}$], [100], [20], [80],
  ),
  caption: [
    Bảng phục vụ tính Giá trị Shapley cho người chơi $A$
  ],
) <demo-fish-2>

#figure(
  table(
    columns: 6,
    align: (left, left, left, right, right, right),

    [*$cal(O)$*],
    [*$S union {k}$*],
    [*$S$*],
    [*$f_(cal(O) union {i})$*],
    [*$f_cal(O)$*],
    [*$f_(cal(O) union {k}) - f_cal(O)$*],

    [${A, B, C}$], [$\{A, B\}$], [$\{A\}$], [70], [30], [40],
    [${A, C, B}$], [$\{A, B, C\}$], [$\{A, C\}$], [100], [70], [30],
    [${B, A, C}$], [$\{B\}$], [$\{emptyset\}$], [20], [0], [20],
    [${B, C, A}$], [$\{B\}$], [$\{emptyset\}$], [20], [0], [20],
    [${C, A, B}$], [$\{A, B, C\}$], [$\{A, C\}$], [100], [70], [30],
    [${C, B, A}$], [$\{B, C\}$], [$\{C\}$], [20], [20], [0],
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
  phi_B = phi_C = (40 + 30 + 20 + 20 + 30 + 0)∕6 approx 23.3
$

Kiểm tra lại tính hiệu quả $phi_A + phi_B + phi_C = 100$ đúng với @demo-fish-1.

== 2.3. Giá trị Shapley đối với sự quan trọng của đặc trưng

Nếu thay đổi trò chơi thành bài toán hồi quy, cụ thể là dự đoán kết quả các đặc trưng, ta vẫn có thể áp dụng Giá trị Shapley để giải thích. Xét một bài toán máy học tiêu chuẩn: có tập huấn luyện $cal(D)^("train")$ với $J$ đặc trưng $x_1, ..., x_J$ và giá trị $y$ là kết quả cần dự đoán, dùng để huấn luyện mô hình $f : cal(A) arrow.r RR$ với $cal(A) in cal(A)_1 times cal(A)_2 times ... times cal(A)_J$. Các đặc trưng đóng vai như người chơi trong trò chơi dự đoán kết quả này, mục đích là để tìm mức độ đóng góp của từng đặc trưng ảnh hưởng đến kết quả dự đoán tại một điểm dữ liệu cụ thể $x$.

Công thức tính phần thưởng cũng như là mức độ đóng góp của đặc trưng được định nghĩa như sau:

$
  v(S)(x) = sum_(z in cal(A)) p(z)(f(tau(x, z, S)) - f(z))
$ <math-shapley-value-feature-reward>

với $tau(x, z, S) = (u_1, ..., u_J)$ với điều kiện $u_j = x_j$ nếu $j in S$ và $u_j = z_j$ nếu $j in.not S$. $z$ là điểm dữ liệu ngẫu nhiên (random data points) vẫn lấy từ không gian $cal(A)$, $p(z)$ là phân phối của các điểm dữ liệu ngẫu nhiên $z$ trong không gian $cal(A)$.

Do đó công thức tính Giá trị Shapley cho đặc trưng $j$ là:

$
  phi_j(x) = frac(1, J!) sum_(cal(O) in pi(J)) sum_(z in A) p(z) [f(tau(x, z, "Pre"^j (cal(O) union {j}))) - f(tau(x, z, "Pre"^j (cal(O))))]
$ <math-shapley-value-feature-1>

với $pi(J)$ là tập hợp tất cả các hoán vị của tập $J$ đặc trưng, $"Pre"^j (cal(O))$ là tập hợp tất cả các đặc trưng có vị trí ở trước đặc trưng $j$ khi sắp xếp trong hoán vị $cal(O) in pi(J)$. Và vì $f(z)$ đều xuất hiện trong công thức $v("Pre"^j (cal(O) union {j}))$ và $v("Pre"^j (cal(O)))$, nên chúng bị triệt tiêu, không xuất hiện trong @math-shapley-value-feature-1. Để đơn giản chúng ta giả sử tập $cal(A)$ là rời rạc.

Tuy nhiên thông thường chúng ta không biết được phân phối $p(z)$, và số các liên minh của $N$ đặc trưng là $2^(|N|)$ khi số đặc trưng tăng lên thì số các liên minh cũng tăng lên rất nhanh, nên việc tính chính xác $v(S)$ gần như là không thể. Để đơn giản hơn, [TODO] đề xuất sử dụng phân phối mẫu ngẫu nhiên (random sampling) và thuật toán xấp xỉ đề viết lại Giá trị Shapley xấp xỉ như sau:

$
  hat(phi)_j (x) = 1/M sum_(m=1)^M [f(tau(x, z^m, "Pre"^j (cal(O)^m union {j}))) - f(tau(x, z^m, "Pre"^j (cal(O)^m)))]
$ <math-shapley-value-feature-2>

@math-shapley-value-feature-2 thay vì tìm toàn bộ hoán vị của toàn bộ liên minh, thay vào đó chỉ lấy $M$ mẫu ngẫu nhiên. Với từng mẫu ngẫu nhiên $m$, ta có được hoán vị $cal(O) in pi(J)$ và điểm dữ liệu $z^m in cal(A)$ theo phân phối $p$.$p$. Vì $p$ không biết nên khi tính toàn ta lấy mẫu theo tập dữ liệu [TODO].


== 2.4. Giá trị Shapley đối với sự quan trọng của cụm dữ liệu

Dựa trên Giá trị Shapley đối với sự quan trọng của đặc trưng, bài báo *Shapley values for cluster importance* [TODO] đề xuất phương pháp XAI mới để giải thích mức độ quan trọng của từng cụm dữ liệu trong tập dữ liệu huấn luyện thay vì đặc trưng trong dự đoán. Trò chơi và phần thưởng vẫn được định nghĩa tương tự, chúng ta thay đổi định nghĩa người chơi trở thành các tập con trong tập dữ liệu huấn luyện, để nhằm giải thích dự đoán bị ảnh hưởng bởi các cụm dữ liệu huấn luyện như thế nào.

Như ở chương trước, chúng ta vẫn sẽ sử dụng hàm hồi quy để minh hoạ $f : cal(A) arrow.r RR$ với $cal(A) in cal(A)_1 times cal(A)_2 times ... times cal(A)_J$. Tập dữ liệu huấn luyện được chia thành $K$ cụm dữ liệu $cal(Q)_k$ không giao nhau, sao cho $cal(Q)_1 union ... union cal(Q)_K$ chính là toàn bộ tập dữ liệu huấn luyện $cal(D)^("train")$. Cách chia cụm dữ liệu huấn luyện ảnh hưởng trực tiếp đến việc giải thích dự đoán. Ví dụ có thể chia thành các cụm theo thời gian, cụ thể là 12 tháng trong năm. Hoặc lấy riêng từng điểm dữ liệu làm từng cụm cụ thể, lúc này thay vì trả lời cho câu hỏi cụm dữ liệu nào ảnh hưởng đến kết quả dự đoán thì sẽ trả lời cho câu hỏi điểm dữ liệu cụ thể nào ảnh hưởng đến kết quả dự đoán nhất.

Trò lại với trò chơi liên minh, các cụm $cal(Q)_k$ là người chơi và hàm phần thường được định nghĩa như sau:

$
  v(S)(x) = f_S (x)
$ <math-shapley-value-cluster-reward>

trong đó $f_S (x)$ là hàm dự đoán được huấn luyện từ hợp của các $cal(Q)_k$ với $k in S subset.eq N$.

Giá trị Shapley cho cụm dữ liệu $k$ được định nghĩa như sau:

$
  phi_k(x) = frac(1, K!) sum_(cal(O) in pi(K)) (f_("Pre"^k (cal(O) union {k}))(x) - f_("Pre"^k (cal(O)))(x))
$ <math-shapley-value-cluster-1>

trong đó $pi(K)$ là tập hợp tất cả các hoán vị của tập $K$ cụm dữ liệu, $"Pre"^k (cal(O))$ là tập hợp tất cả các cụm dữ liệu có vị trí ở trước cụm dữ liệu $k$ khi sắp xếp trong hoán vị $cal(O) in pi(K)$.

Áp dụng cách xấp xỉ tương tự như @math-shapley-value-feature-2, ta có thể viết lại công thức Giá trị Shapley cho cụm dữ liệu $k$ một cách xấp xỉ như sau:

$
  hat(phi)_k (x) = 1/M sum_(m=1)^M (f_("Pre"^k (cal(O)^m union {k}))(x) - f_("Pre"^k (cal(O)^m))(x))
$

Với từng mẫu ngẫu nhiên $m$, ta có được hoán vị $cal(O) in pi(K)$ lấy ngẫu nhiên theo phân phối uniform [TODO].

Đối với trường hợp chúng ta không có dữ liệu, tương đương với $S = zero.slashed$, ta định nghĩa dự đoán bằng $0$, tương đương với $f_zero.slashed (x) = 0$ với mọi $x in cal(A)$. Điều này tương đương với tính chất người chơi zero trong Giá trị Shapley $v(zero.slashed) = 0$, nghĩa là nếu không có dữ liệu huấn luyện thì dự đoán sẽ bằng 0.

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
  phi_k (x) = frac(1, K!) sum_(cal(O) in pi(K)) [(y - f_("Pre"^k (cal(O) union {k}))(x))^2 - (y - f_("Pre"^k (cal(O)))(x))^2]
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

Có một vấn đề là tính chất *Người chơi zero* không còn đúng nữa vì với $f_zero.slashed (x) = 0$ thì $v(zero.slashed) = (y - 0)^2 = y^2$ chứ không phải bằng 0 theo @math-shapley-value-hindsight-reward-1.

Để giải quyết vấn đề này, chúng ta có thể định nghĩa lại hàm phần thưởng $v$ như sau:

$
  v(S)(x) = (y - f_S (x))^2 - y^2
$ <math-shapley-value-hindsight-reward-2>

khi đó nếu $f_S (x) = 0$ thì $v(S)(x) = (y - 0)^2 - y^2 = 0$ đúng với tính chất *Người chơi zero*. Và vì $y^2$ là cố định trong cả 2 hàm phần thưởng $v("Pre"^k (cal(O) union {k}))$ và $v("Pre"^k (cal(O)))$, nên chúng bị triệt tiêu trong @math-shapley-value-hindsight-1. Do đó Giá trị Shapley của 2 hàm phần thưởng @math-shapley-value-hindsight-reward-1 và @math-shapley-value-hindsight-reward-2 là giống nhau.

Áp dụng cách xấp xỉ tương tự như @math-shapley-value-feature-2, ta có thể viết lại công thức Giá trị Shapley cho cụm dữ liệu $k$ một cách xấp xỉ như sau:

$
  hat(phi)_k (x) = 1/M sum_(m=1)^M [(y - f_("Pre"^k (cal(O)^m union {k}))(x))^2 - (y - f_("Pre"^k (cal(O)^m))(x))^2]
$

Với từng mẫu ngẫu nhiên $m$, ta có được hoán vị $cal(O) in pi(K)$ lấy ngẫu nhiên theo phân phối uniform [TODO].

Thuật toán để tính được xấp xỉ Giá trị Shapley cho từng cụm dữ liệu $k$ tại điểm dữ liệu $x$ cục bộ được trình bày như sau:

#pseudocode-list(
  booktabs: true,
  line-numbering: none,
)[
  - *Khởi tạo:*
  - Số lần lặp $M$;
  - Chia dữ liệu huấn luyện thành các cụm: $Q_1, Q_2, ..., Q_k$;
  - $phi_k (x) := 0$;
  + *for* $m = 1, ..., M$ *do*
    + Lấy mẫu một hoán vị ngẫu nhiên $cal(O) in pi(K)$;
    + Tạo tập dữ liệu $cal(D)^+$ gồm $Q_k$ và các $Q_i$ với $i$ đứng trước $k$ trong $cal(O)$;
    + Dùng tập dữ liệu $cal(D)^+$ để huấn luyện một hàm $f_(cal(D)^+)$;
    + Tạo tập dữ liệu $cal(D)^-$ gồm các $Q_i$ với $i$ đứng trước $k$ trong $cal(O)$;
    + Dùng tập dữ liệu $cal(D)^-$ để huấn luyện một hàm $f_(cal(D)^-)$;
    + Cập nhật giá trị Shapley: \
      $phi_k (x) := phi_k (x) + (y - f_(cal(D)^+)(x))^2 - (y - f_(cal(D)^-)(x))^2$
  + *end*
  + $phi_k (x) := frac(phi_k (x), M)$;
] <algorithm-shapley-value-hindsight>

== 3.2. Giải thích toàn cục

Nếu như Mục 3.1 giải thích cục bộ cho từng dự đoán riêng lẻ tại từng thời điểm cụ thể, chúng ta có thể định nghĩa lại hàm phần thưởng cho việc đánh giá hiệu quả toàn cục (global performance, đó là hiệu quả của toàn bộ tập dữ liệu kểm thử $cal(D)^"test"$ thay vì từng dự đoán riêng lẻ. Ví dụ chúng ta định nghĩa hàm phần thưởng $v$ sử dụng MSE như sau:

$
  macron(v)(S) = 1/T sum_(t=1)^T (y_t - f_S (x_t))^2
$ <math-shapley-value-hindsight-reward-3>

trong đó $T$ là toàn bộ điểm dữ liệu trong tập kiểm thử $cal(D)^"test"$.

*Mệnh đề 1.* Giá trị Shapley toàn cục đối với trò chơi sử dụng MSE @math-shapley-value-hindsight-reward-3 bằng trung bình cộng của toàn bộ giá trị Shapley riêng lẻ sử dụng sai số bình phương @math-shapley-value-hindsight-reward-1.

*Chứng minh.* Giá trị Shapley toàn cục $macron(phi)_k$ của cụm dữ liệu $k$ được định nghĩa như sau:

$
  macron(phi)_k = 1/(K!) sum_(cal(O) in pi(K)) [ 1/T sum_(t=1)^T (y_t - f_("Pre"^k (cal(O)) union {k}) (x_t))^2 - 1/T sum_(t=1)^T (y_t - f_("Pre"^k (cal(O))) (x_t))^2 ] \
  = 1/T sum_(t=1)^T 1/(K!) sum_(cal(O) in pi(K)) [ (y_t - f_("Pre"^k (cal(O)) union {k}) (x_t))^2 - (y_t - f_("Pre"^k (cal(O))) (x_t))^2 ] \
  = 1/T sum_(t=1)^T phi_k (x_t).
$

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

$
  hat(phi)_k = 1/M sum_(m=1)^M [h_("Pre"^k (cal(O)^m union {k})) - h_("Pre"^k (cal(O)^m))]
$

#pagebreak()

= Chương 4. KẾT QUẢ NGHIÊN CỨU VÀ PHÂN TÍCH, ĐÁNH GIÁ, THẢO LUẬN

== 4.1. Dữ liệu tạo sinh

Trước khi sử dụng dữ liệu thực tế, chúng ta sẽ thử nghiệm phương pháp đề xuất ở Chương 3 trên tập dữ liệu tạo sinh (synthetic data). Ưu điểm của dữ liệu tạo sinh là chúng ta biết chính xác quy luật tạo sinh dữ liệu: hàm quyết định, phân phối nhiễu cũng như mối quan hệ giữa các cụm dữ liệu. Nhờ đó, chúng ta có thể thiết kế các cụm với những tính chất đã biết trước, rồi kiểm chứng xem Giá trị Shapley cho cụm dữ liệu có phản ánh đúng các tính chất lý thuyết đã trình bày ở Chương 2 và Chương 3 hay không, trước khi áp dụng phương pháp vào dữ liệu thực tế vốn không có thông tin sẵn có như vậy.

Chúng ta đề xuất một bài toán hồi quy mô phỏng theo chuỗi thời gian đơn giản:

$
  x_j(t) = sin(omega_j t) + eta_j(t), quad j = 1, dots, 4
$ <math-synthetic-x>

trong đó $t = 1, dots, T$, và $eta_j(t) tilde cal(N)(0, 0.1)$ là độ nhiễu gauss cộng vào từng thời điểm. Bốn đặc trưng được thiết kế để dao động với tần số khác nhau rõ rệt, nhờ đó mỗi đặc trưng mang thông tin về chu kỳ thời gian riêng; trong thực nghiệm, để kết quả có thể tái lập được, các biến $omega_j$ được chọn cố định cho từng đặc trưng thay vì lấy mẫu ngẫu nhiên.

Dựa vào đó, định nghĩa hàm sinh dữ liệu:

$
  y(t) = x_1(t) dot x_2(t) + x_3(t) dot x_4(t) + epsilon(t)
$ <math-synthetic-y>

trong đó các $x_j$ là các biến có thể giải thích được (explanatory variables), và biến số nhiễu $epsilon(t)$ tuân theo phân phối độc lập cùng phân phối (i.i.d.) $cal(N)(0, 0.1)$. Khác với dữ liệu thực tế, ở đây ta biết chính xác rằng $y$ chỉ được sinh từ hàm phi tuyến $x_1 dot x_2 + x_3 dot x_4$ kết hợp 2 cặp đặc trưng $(x_1, x_2)$ và $(x_3, x_4)$; do đó mọi sai số dự đoán của mô hình so với $y$ đều bắt nguồn từ 2 nguồn: nhiễu $epsilon$ và những vùng dữ liệu mà mô hình chưa học tốt. Dữ liệu tạo sinh này sẽ dùng để huấn luyện mô hình Random Forest, với 100 cây và số lượng nút lá tối đa là 30.

Chúng ta mô phỏng 400 điểm dữ liệu từ mô hình trên để tạo thành tập huấn luyện, sau đó chia thành 4 cụm, mỗi cụm gồm 100 điểm liên tiếp. Tiếp theo, chúng ta nhân bản cụm thứ 4 để tạo thành cụm thứ 5, sao cho tập huấn luyện gồm 500 điểm và 5 cụm $cal(Q)_1, ..., cal(Q)_5$; chúng ta thực hiện tương tự cho tập kiểm thử. Thiết kế này cho phép minh hoạ tính đối xứng của Giá trị Shapley (@math-shapley-value-symmetry): khi 2 cụm dữ liệu huấn luyện giống nhau, Giá trị Shapley của chúng cũng bằng nhau $phi_4 = phi_5$.

Do tính chất chủ quan và mang tính xấp xỉ của các phương pháp giải thích, việc kiểm chứng chất lượng và độ tin cậy của một lời giải thích là khó khăn. Hall and Gill [TODO] đề xuất sử dụng dữ liệu mô phỏng với hàm sinh tín hiệu đã biết trước để kiểm tra xem lời giải thích có phản ánh đúng hàm đã biết đó hay không. Vì vậy, trong thực nghiệm này, chúng ta đặt tập kiểm thử trùng với tập huấn luyện, tức là Giá trị Shapley cục bộ $hat(phi)_k (x)$ được tính ngay tại các điểm dữ liệu huấn luyện. Cách làm này phi thực tế trong ứng dụng, nhưng giúp kết quả giải thích dễ hiểu và dễ kiểm chứng. @figure-synthetic-train-data minh hoạ tập dữ liệu: 5 màu tương ứng với 5 cụm, ranh giới giữa các cụm nằm tại các vị trí 100, 200, 300 và 400; tại vị trí 400, giá trị của các đặc trưng quay lại đoạn giá trị của cụm $cal(Q)_4$ — hệ quả trực tiếp của việc nhân bản cụm thứ 4.

#figure(
  image("figures/synthetic_00_train_data.png", width: 85%),
  caption: [Dữ liệu huấn luyện của tập dữ liệu tạo sinh: $y$ và 4 đặc trưng $x_1, x_2, x_3, x_4$ theo thời gian; màu sắc thể hiện 5 cụm dữ liệu],
) <figure-synthetic-train-data>

Khi giải thích các dự đoán, chúng ta sẽ không can thiệp hoặc kiểm tra mô hình được dùng để tạo ra các dự đoán đó (mô hình hộp đen) mà chỉ sử dụng để huấn luyện lại với tập dữ liệu mới, kể cả việc không chỉnh sửa các siêu tham số (hyper-parameter) trong mô hình. Đối với giai đoạn tính Giá trị Shapley, chúng ta sử dụng $M = 250$ hoán vị ngẫu nhiên theo phân phối uniform. Kết quả được quan sát dưới 2 dạng: Giá trị Shapley toàn cục của từng cụm theo số lần lặp $M$ để kiểm tra mức độ hội tụ, và Giá trị Shapley cục bộ tại 5 điểm dữ liệu đại diện, mỗi điểm nằm ở giữa đoạn của một cụm trong tập huấn luyện.

== 4.2. Giải thích dự đoán

Trước khi chuyển sang giải thích sai số bình phương, chúng ta trình bày lời giải thích cho dự đoán. Giá trị Shapley giải thích dự đoán của 5 điểm dữ liệu được chọn (đánh dấu màu đỏ ở biểu đồ phía trên) được trình bày trong @figure-synthetic-explain-predictions. Ở biểu đồ phía trên của @figure-synthetic-explain-predictions, giá trị dự đoán được vẽ cho toàn bộ 500 điểm của tập kiểm thử — trùng với tập huấn luyện được minh hoạ trong @figure-synthetic-train-data. Các dự đoán được tạo ra bởi mô hình được huấn luyện trên toàn bộ tập huấn luyện gồm tất cả các cụm, tức là các dự đoán được thực hiện bởi mô hình khớp $f_N$. Ở hàng giữa của @figure-synthetic-explain-predictions, lời giải thích cho 5 điểm dữ liệu được chọn được thể hiện: Giá trị Shapley ước lượng cho mức độ quan trọng của 5 cụm được vẽ dưới dạng biểu đồ cột với màu tương ứng của từng cụm. Các biểu đồ ở hàng dưới cho thấy ước lượng Giá trị Shapley phát triển như thế nào khi số mẫu $m$ tăng từ 1 đến $M = 250$.

Khi diễn giải lời giải thích, phép tương tự với Lý thuyết trò chơi liên minh rất hữu ích. Giá trị Shapley của một trò chơi liên minh phân chia phần thưởng của trò chơi một cách công bằng giữa những người chơi hợp tác. Như đã trình bày, trong trò chơi của chúng ta, các cụm dữ liệu huấn luyện đóng vai người chơi và dự đoán là phần thưởng. Do đó, chúng ta diễn giải Giá trị Shapley của một cụm là mức đóng góp của cụm đó vào dự đoán. Ví dụ, xét điểm dữ liệu đầu tiên tại thời điểm $t = 50$, Giá trị Shapley cho thấy cụm thứ 1 đóng góp làm tăng dự đoán, trong khi 4 cụm còn lại đóng góp làm giảm dự đoán. Dự đoán tại 2 điểm dữ liệu tiếp theo được giải thích ($t = 150$ và $t = 250$) bị giảm đáng kể bởi cụm 2 và cụm 3 tương ứng; cả 2 điểm này đều có giá trị thực tế thấp hơn 0 nhiều. Ngoài ra, 2 thời điểm cuối, vốn có các điểm dữ liệu cần giải thích giống hệt nhau, thể hiện các bộ Giá trị Shapley xấp xỉ bằng nhau.

#figure(
  image("figures/synthetic_02_predictions.png", width: 100%),
  caption: [Giải thích dự đoán của tập dữ liệu tạo sinh: (hàng trên) dự đoán của mô hình $f_N$ trên toàn bộ 500 điểm của tập kiểm thử cùng 5 điểm được chọn; (hàng giữa) Giá trị Shapley của từng cụm cho 5 điểm được chọn; (hàng dưới) sự hội tụ của Giá trị Shapley theo số lần lặp $M$],
) <figure-synthetic-explain-predictions>

@figure-synthetic-global-convergence trình bày sự hội tụ của Giá trị Shapley toàn cục của từng cụm theo số lần lặp $M$. Các đường gần như ổn định từ khoảng 100 lần lặp trở đi, xác nhận $M = 250$ là đủ lớn. Bên cạnh đó, đường của cụm 4 gần như trùng với đường của cụm 5, phù hợp với tính đối xứng $phi_4 = phi_5$ đã trình bày ở Mục 4.1.

#figure(
  image("figures/synthetic_01_predictions_number_iterations.png", width: 85%),
  caption: [Sự hội tụ của Giá trị Shapley toàn cục của từng cụm theo số lần lặp $M$ trên tập dữ liệu tạo sinh],
) <figure-synthetic-global-convergence>

Để minh chứng tính độc lập với mô hình (model agnostic), chúng ta lặp lại thí nghiệm giải thích dự đoán ở trên với một mô hình hộp đen hoàn toàn khác: hồi quy k láng giềng gần nhất (K-Nearest Neighbors) với $k = 10$ (kNN 10), cài đặt bằng hàm `knn.reg` (TODO). Khác với Rừng Ngẫu Nhiên là mô hình ensemble dựa trên cây quyết định, kNN là mô hình dựa trên mẫu (instance-based): dự đoán tại một điểm mới được tính bằng trung bình giá trị của 10 điểm huấn luyện gần nhất trong không gian đặc trưng. Toàn bộ cấu hình còn lại — dữ liệu tạo sinh, cách phân cụm, cách chia dữ liệu và $M = 250$ hoán vị — được giữ nguyên; chỉ mô hình dự đoán thay đổi.

@figure-synthetic-knn10-global-convergence trình bày sự hội tụ của Giá trị Shapley toàn cục theo số lần lặp $M$, và @figure-synthetic-knn10-explain-predictions trình bày lời giải thích cục bộ tại 5 điểm dữ liệu đại diện, tương tự như với Rừng Ngẫu Nhiên. Vì mô hình dự đoán thay đổi, mức đóng góp của từng cụm dữ liệu vào dự đoán cũng thay đổi theo; điều này là hợp lý, vì mỗi mô hình khai thác các cụm dữ liệu theo cách khác nhau. Điều quan trọng là quy trình giải thích — từ cách định nghĩa trò chơi, thuật toán xấp xỉ đến cách diễn giải kết quả — vẫn hoạt động không thay đổi trên một mô hình hoàn toàn khác, chứng minh tính độc lập với mô hình của phương pháp.

#figure(
  image("figures/synthetic_03_predictions_number_iterations_knn10.png", width: 85%),
  caption: [Sự hội tụ của Giá trị Shapley toàn cục của từng cụm theo số lần lặp $M$ với mô hình kNN 10 trên tập dữ liệu tạo sinh],
) <figure-synthetic-knn10-global-convergence>

#figure(
  image("figures/synthetic_04_predictions_knn10.png", width: 100%),
  caption: [Giải thích dự đoán với mô hình kNN 10 trên tập dữ liệu tạo sinh: (hàng trên) dự đoán trên 500 điểm của tập kiểm thử cùng 5 điểm được chọn; (hàng giữa) Giá trị Shapley của 5 cụm cho từng điểm được chọn; (hàng dưới) sự hội tụ của Giá trị Shapley theo số lần lặp $M$],
) <figure-synthetic-knn10-explain-predictions>

== 4.3. Giải thích sai số bình phương

@figure-synthetic-explain-squared-error trình bày các lời giải thích liên quan đến sai số bình phương của dự đoán, theo trò chơi đã trình bày ở Mục 3.1 (@math-shapley-value-hindsight-reward-1). Các Giá trị Shapley này cho thấy từng cụm dữ liệu đóng góp như thế nào để giảm hoặc tăng sai số bình phương tại 5 điểm dữ liệu được chọn. Lưu ý rằng trò chơi này đòi hỏi biết trước giá trị thực tế $y$ tương ứng của mỗi điểm.

Nhắc lại rằng trong thí nghiệm này, chúng ta chọn tập kiểm thử trùng với tập huấn luyện. Đối với mô hình Rừng Ngẫu Nhiên, dự đoán thường tốt hơn khi dữ liệu cần dự đoán giống với dữ liệu huấn luyện. Vì vậy, với bất kỳ điểm dữ liệu $x$ thuộc cụm $k$ nào đó, việc đưa cụm $k$ vào tập huấn luyện sẽ làm giảm sai số dự đoán, và do đó Giá trị Shapley của cụm $k$, $phi_k$, sẽ âm. Ví dụ, trong tập huấn luyện, điểm dữ liệu 150 thuộc cụm thứ 2. Khi tính sai số bình phương của điểm 150 trong tập kiểm thử — trùng với điểm 150 trong tập huấn luyện — Giá trị Shapley của cụm 2 là âm. Điều này nghĩa là, như kỳ vọng, cụm 2 đóng góp làm giảm sai số bình phương.

Chúng ta cũng quan sát thấy Giá trị Shapley của cụm 4 và cụm 5 rất giống nhau, cũng như kỳ vọng vì 2 cụm này là giống hệt nhau (Mục 4.1). Lời giải thích tại thời điểm $t = 350$ và $t = 450$ cho thấy cụm thứ 3 của tập huấn luyện đóng góp đáng kể làm tăng sai số bình phương, và do đó làm giảm hiệu suất dự đoán.

// TODO: thay thế ảnh placeholder bằng ảnh plot thật (layout 3 hàng ở chế độ giải thích sai số bình phương)
#figure(
  image("figures/synthetic_06_squared_error.png", width: 100%),
  caption: [Giải thích sai số bình phương của tập dữ liệu tạo sinh: (hàng trên) sai số bình phương trên 500 điểm của tập kiểm thử cùng 5 điểm được chọn; (hàng giữa) Giá trị Shapley của 5 cụm cho từng điểm được chọn; (hàng dưới) sự hội tụ của Giá trị Shapley theo số lần lặp $M$],
) <figure-synthetic-explain-squared-error>

@figure-synthetic-squared-error-convergence trình bày sự hội tụ của Giá trị Shapley toàn cục theo số lần lặp $M$ cho trò chơi sai số bình phương. Các đường ổn định sau một số lượng lặp nhất định, xác nhận $M = 250$ là đủ lớn; bên cạnh đó, đường của cụm 4 gần như trùng với đường của cụm 5 — một lần nữa nhất quán với tính đối xứng $phi_4 = phi_5$ đã trình bày ở Mục 4.1.

// TODO: thay thế ảnh placeholder bằng ảnh plot thật (global Shapley values, chế độ sai số bình phương)
#figure(
  image("figures/synthetic_05_squared_error_number_iterations.png", width: 85%),
  caption: [Sự hội tụ của Giá trị Shapley toàn cục của từng cụm theo số lần lặp $M$ cho trò chơi sai số bình phương trên tập dữ liệu tạo sinh],
) <figure-synthetic-squared-error-convergence>

Tương tự như Mục 4.2, chúng ta lặp lại thí nghiệm giải thích sai số bình phương với mô hình kNN 10 để minh chứng tính độc lập với mô hình của phương pháp. @figure-synthetic-knn10-squared-error-convergence và @figure-synthetic-knn10-squared-error trình bày lần lượt sự hội tụ của Giá trị Shapley toàn cục theo số lần lặp $M$ và lời giải thích sai số bình phương tại 5 điểm dữ liệu đại diện. Vì mô hình dự đoán thay đổi so với Rừng Ngẫu Nhiên, mức đóng góp của từng cụm dữ liệu cũng thay đổi theo; điều này là hợp lý, vì mỗi mô hình khai thác các cụm dữ liệu theo cách khác nhau. Điều quan trọng là quy trình giải thích vẫn hoạt động không thay đổi, một lần nữa khẳng định tính độc lập với mô hình của phương pháp.

// TODO: thay thế ảnh placeholder bằng ảnh plot thật (global Shapley values, sai số bình phương, kNN 10)
#figure(
  image("figures/synthetic_07_squared_error_number_iterations_knn10.png", width: 85%),
  caption: [Sự hội tụ của Giá trị Shapley toàn cục của từng cụm theo số lần lặp $M$ với mô hình kNN 10 cho trò chơi sai số bình phương trên tập dữ liệu tạo sinh],
) <figure-synthetic-knn10-squared-error-convergence>

// TODO: thay thế ảnh placeholder bằng ảnh plot thật (layout 3 hàng, sai số bình phương, kNN 10)
#figure(
  image("figures/synthetic_08_squared_error_knn10.png", width: 100%),
  caption: [Giải thích sai số bình phương với mô hình kNN 10 trên tập dữ liệu tạo sinh: (hàng trên) sai số bình phương trên 500 điểm của tập kiểm thử cùng 5 điểm được chọn; (hàng giữa) Giá trị Shapley của 5 cụm cho từng điểm được chọn; (hàng dưới) sự hội tụ của Giá trị Shapley theo số lần lặp $M$],
) <figure-synthetic-knn10-squared-error>

== 4.4. Phân loại

Tiếp tục với chuỗi dữ liệu thời gian tạo sinh từ @math-synthetic-x và @math-synthetic-y, với tập kiểm thử trùng với tập huấn luyện, chúng ta xét bài toán phân loại. Để minh hoạ Giá trị Shapley cho độ chính xác phân loại — độ đo đã trình bày ở Mục 3.3 — chúng ta tạo ra một tập các điểm bất thường bằng cách thay đổi một phần của tập kiểm thử. Cụ thể, tín hiệu $x_1$ được thay bằng $x_1^*$:

$
  x_1^*(t) = x_1(t) + eta^*(t), quad t in [200, 250)
$ <math-anomaly-x1>

và tín hiệu $x_4$ được thay bằng $x_4^*$:

$
  x_4^*(t) = x_4(t) + eta^*(t), quad t in [300, 350)
$ <math-anomaly-x4>

trong đó $eta^*(t) tilde cal(N)(-0.5, 0.5)$. Như vậy, tổng cộng có 100 điểm dữ liệu bị thay đổi (với $t in [200, 250) union [300, 350)$), và 400 điểm còn lại được giữ nguyên. Tập kiểm thử mới được minh hoạ trong @figure-synthetic-test-anomalies, các điểm bị thay đổi được tô màu đỏ. 100 điểm bị thay đổi được coi là bất thường, 400 điểm còn lại được coi là bình thường. Ví dụ, nếu cả 100 điểm bất thường đều được phát hiện, số lượng dương tính thật (TP) sẽ bằng 100, và 400 điểm còn lại nên được phân loại là bình thường, khi đó số lượng âm tính thật (TN) bằng 400. Nếu một điểm bị thay đổi nhưng được phân loại là bình thường, số lượng báo động bị bỏ sót — âm tính giả (FN) — sẽ tăng lên; tương tự, nếu một điểm không bị thay đổi nhưng được phân loại là bất thường, đây được xem là báo động giả, làm tăng số lượng dương tính giả (FP).

#figure(
  image("figures/synthetic_09_classification_test_data_anomalies.png", width: 85%),
  caption: [Tập kiểm thử của tập dữ liệu tạo sinh với các điểm bất thường được tô màu đỏ: $x_1$ bị thay đổi với $t in [200, 250)$ và $x_4$ bị thay đổi với $t in [300, 350)$],
) <figure-synthetic-test-anomalies>

Mục tiêu của bộ phân loại $g(t)$ là dự đoán có hay không xuất hiện điểm bất thường tại thời điểm $t$ trong tập kiểm thử. Để làm điều đó, chúng ta áp dụng một phương pháp tái tạo tín hiệu đa biến kết hợp với phân tích phần dư [TODO]. Cách tiếp cận là so sánh tín hiệu gốc với một bản tái tạo của chính nó: nếu bản tái tạo khác tín hiệu gốc đủ lớn (vượt quá một ngưỡng $L$ nào đó), điểm dữ liệu được phân loại là bất thường; ngược lại, nếu khác biệt nhỏ, điểm dữ liệu được phân loại là bình thường. Tín hiệu được tái tạo bằng hồi quy hạt nhân tự kết hợp (Auto Associative Kernel Regression, AAKR) — phương pháp so sánh độ tương tự giữa dữ liệu huấn luyện được lưu trong bộ nhớ và vectơ truy vấn (dữ liệu kiểm thử), rồi gán trọng số cao cho các vectơ có độ tương tự cao để tính ra vectơ ước lượng [TODO]. Một tham số băng thông $h$ được sử dụng để điều khiển hàm trọng số tính các trọng số này. Có nhiều kỹ thuật có thể dùng để tinh chỉnh/tối ưu tham số này; vì mục tiêu ở đây là minh hoạ, chúng ta không tinh chỉnh mà đơn giản đặt $h = 0.2$; tương tự, chúng ta chọn ngưỡng $L = 0.5$ làm ranh giới giữa lớp bình thường và lớp bất thường. @figure-synthetic-classification-compare-train-aakr và @figure-synthetic-classification-compare-test-aakr minh hoạ quá trình tái tạo: lần lượt so sánh tập huấn luyện và tập kiểm thử với các tín hiệu ước lượng được tái tạo bởi AAKR (đường màu đỏ).

// TODO: thay thế ảnh placeholder bằng ảnh plot thật (AAKR trên tập huấn luyện)
#figure(
  image("figures/synthetic_10_classification_compare_train_aakr.png", width: 85%),
  caption: [So sánh tập huấn luyện với tín hiệu ước lượng được tái tạo bởi AAKR trên tập dữ liệu tạo sinh],
) <figure-synthetic-classification-compare-train-aakr>

// TODO: thay thế ảnh placeholder bằng ảnh plot thật (AAKR trên tập kiểm thử)
#figure(
  image("figures/synthetic_11_classification_compare_test_aakr.png", width: 85%),
  caption: [So sánh tập kiểm thử với tín hiệu ước lượng được tái tạo bởi AAKR trên tập dữ liệu tạo sinh],
) <figure-synthetic-classification-compare-test-aakr>

Sau khi tất cả các điểm dữ liệu trong tập kiểm thử được phân loại là bình thường hoặc bất thường, các lớp được dự đoán được so sánh với phân loại thực tế. Ví dụ, nếu $g$ phân loại điểm dữ liệu tại $t = 225$ là bất thường, đây là một dương tính thật (TP), vì điểm này đã bị thay đổi nên trạng thái thực của nó thực sự là bất thường. Dựa trên số lượng TP, TN, FP và FN, chúng ta tính độ chính xác $h$ theo @math-accuracy.

Để định lượng mức đóng góp của 5 cụm dữ liệu vào độ chính xác, chúng ta xấp xỉ Giá trị Shapley cho độ đo độ chính xác như đã trình bày ở Mục 3.3; kết quả được trình bày trong @figure-synthetic-shapley-accuracy. Như đã giải thích ở trên, khi sử dụng mô hình Rừng Ngẫu Nhiên để dự đoán, dữ liệu huấn luyện giống với dữ liệu kiểm thử sẽ đảm bảo độ chính xác dự đoán cao. Vì tập kiểm thử và tập huấn luyện giống hệt nhau — ngoại trừ các điểm thuộc cụm 3 và cụm 4 nơi chúng ta tạo bất thường — chúng ta kỳ vọng các cụm còn lại (cụm 1, 2 và 5) đóng góp nhiều nhất vào việc tăng độ chính xác. Kết quả cho thấy cụm dữ liệu huấn luyện 1 và 2 có Giá trị Shapley cao nhất ($phi_1 = 0.235$ và $phi_2 = 0.22$). Giá trị Shapley của cụm 5 thấp hơn ($phi_5 = 0.171$). Tuy nhiên, điều này cũng đúng như kỳ vọng: cụm 4 và cụm 5 là giống hệt nhau nên 2 cụm này có Giá trị Shapley gần như bằng nhau ($phi_4 = 0.167$ và $phi_5 = 0.171$). Cuối cùng, kết quả cho thấy cụm dữ liệu huấn luyện 3 có Giá trị Shapley thấp nhất ($phi_3 = 0.092$).

// TODO: thay thế ảnh placeholder bằng ảnh plot thật (global Shapley values cho bài toán phân loại)
#figure(
  image("figures/synthetic_12_classification_number_iterations.png", width: 85%),
  caption: [Giá trị Shapley xấp xỉ cho độ chính xác phân loại trên tập dữ liệu tạo sinh],
) <figure-synthetic-shapley-accuracy>

== 4.5. Dữ liệu Bikeshare

Sau khi kiểm chứng phương pháp đề xuất trên dữ liệu tạo sinh, chúng ta tiếp tục thử nghiệm trên một tập dữ liệu thực tế về nhu cầu sử dụng xe đạp công cộng (Bikeshare). Tập dữ liệu Bikeshare được cung cấp sẵn trong thư viện `ISLR2` (TODO) trong ngôn ngữ R, ghi nhận số lượt thuê xe đạp theo từng giờ trong hệ thống xe đạp công cộng tại thành phố Washington D.C., Hoa Kỳ trong 2 năm 2011 và 2012; mỗi quan sát tương ứng với một giờ cụ thể, kèm theo số lượt thuê xe trong giờ đó cùng các thông tin về thời điểm và điều kiện thời tiết tại giờ đó. Sau khi loại bỏ các quan sát không đầy đủ (incomplete cases), tập dữ liệu gồm 8645 điểm dữ liệu. Khác với dữ liệu tạo sinh ở Mục 4.1 vốn được sinh ra từ một hàm toán học biết trước, mối quan hệ giữa các đặc trưng và số lượt thuê xe ở đây không tuân theo công thức nào cả mà chịu ảnh hưởng đồng thời của nhiều yếu tố như giờ trong ngày, ngày làm việc và điều kiện thời tiết, đồng thời có thể thay đổi theo thời gian. Chính vì vậy, tập dữ liệu này phù hợp để đánh giá khả năng giải thích sai số dự đoán của phương pháp trong điều kiện thực tế, nơi nguồn gốc của sai số thường đến từ những vùng dữ liệu khó dự đoán thay vì nhiễu ngẫu nhiên có phân phối đã biết.

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

Tập dữ liệu huấn luyện được chia thành $K$ cụm dữ liệu theo tháng trong năm $cal(Q)_1, ..., cal(Q)_K$ với $K = 12$, trong đó $cal(Q)_k$ bao gồm toàn bộ quan sát có $x_S = k$. Như đã trình bày ở Mục 1.5, nghiên cứu không đề xuất cách phân cụm mới mà cố gắng sử dụng cách phân cụm tự nhiên có sẵn của dữ liệu nếu có thể. Ở đây, yếu tố thời gian theo tháng là lựa chọn dễ thấy nhất: nhu cầu sử dụng xe đạp công cộng mang tính thời vụ rõ rệt, tăng vào những tháng ấm và giảm vào những tháng lạnh, nên việc phân cụm theo tháng giúp các câu hỏi giải thích trở nên có ý nghĩa thực tế, ví dụ như cụm dữ liệu của tháng nào gây ra sai số dự đoán lớn nhất. Bên cạnh đó, vì mỗi tháng có số ngày gần bằng nhau, số quan sát trong mỗi cụm khá cân bằng, dao động từ ít nhất 649 quan sát (tháng 2) đến nhiều nhất 744 quan sát (tháng 5 và tháng 7); sự cân bằng này giúp mức đóng góp của các cụm có thể so sánh trực tiếp với nhau, không bị chi phối bởi chênh lệch kích thước giữa các cụm. @table-bikeshare-cluster-sizes trình bày số quan sát của từng cụm theo tháng.

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
    [$cal(Q)_10$], [743],
    [$cal(Q)_11$], [719],
    [$cal(Q)_12$], [741],
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

Tập $cal(D)^"shapley train"$ được dùng làm dữ liệu huấn luyện để phục vụ việc tính Giá trị Shapley, nghĩa là với mỗi hoán vị $cal(O)$ trong thuật toán xấp xỉ, mô hình $f_S$ được huấn luyện lại từ hợp các cụm $cal(Q)_k$ với $k in S$. Tập $cal(D)^"shapley test"$ gồm các điểm dữ liệu $x$ mà tại đó chúng ta tính Giá trị Shapley cục bộ $hat(phi)_k (x)$ theo thuật toán xấp xỉ đã trình bày ở Mục 3.1. Cuối cùng, tập $cal(D)^"eval"$ hoàn toàn tách biệt và chỉ được dùng để đánh giá cuối cùng, nhằm tránh rò rỉ dữ liệu (data leakage) giữa quá trình giải thích và quá trình đánh giá.

Mô hình hộp đen được sử dụng là Rừng Ngẫu Nhiên (Random Forest). Tương tự như Mục 4.1, chúng ta giả định không có hiểu biết gì về thuật toán bên trong mô hình, nhưng được phép huấn luyện lại mô hình trong quá trình tính Giá trị Shapley. Các thực nghiệm được thực hiện trên cả 2 chế độ: giải thích trực tiếp giá trị dự đoán $f_S (x)$ và giải thích sai số bình phương của dự đoán theo @math-shapley-value-hindsight-reward-2; trong nội dung này chúng ta tập trung vào chế độ giải thích sai số bình phương.

Đối với giai đoạn tính Giá trị Shapley, chúng ta sử dụng $M = 150$ hoán vị ngẫu nhiên theo phân phối uniform. Với mỗi cụm $k$, tập hợp toàn bộ Giá trị Shapley cục bộ $hat(phi)_k (x_t)$ trên $T = 2400$ điểm của tập $cal(D)^"shapley test"$ cho ta Giá trị Shapley toàn cục:

$
  macron(phi)_k = 1/T sum_(t=1)^T hat(phi)_k (x_t)
$

theo *Mệnh đề 1*. Giá trị $macron(phi)_k$ thể hiện mức độ đóng góp trung bình của cụm dữ liệu $k$ vào sai số dự đoán của mô hình. Bên cạnh đó, để minh hoạ tính cục bộ của phương pháp, chúng ta chọn ra 4 tháng trong năm (tháng 1, 4, 8 và 12), tương ứng với 4 điểm dữ liệu $x$, và biểu diễn Giá trị Shapley riêng lẻ của từng cụm cho từng điểm dữ liệu này, cùng với đồ thị hội tụ của chúng theo số lần lặp $M$.

Từ kết quả Giá trị Shapley toàn cục $macron(phi)_k$, chúng ta xây dựng 2 chiến lược thu thập dữ liệu huấn luyện nhằm so sánh hiệu quả. Chiến lược thứ 1 là *equal* (cơ sở): lấy mẫu một số lượng bằng nhau cho mỗi cụm, cụ thể với tổng số $N^"strategy" = 4800$ điểm thì mỗi cụm được lấy $N^"strategy" \/ K = 400$ điểm. Chiến lược thứ 2 là *max* (đề xuất): lấy mẫu nhiều hơn ở những cụm có đóng góp làm giảm sai số dự đoán. Gán trọng số cho từng cụm:

$
  w_k = exp(-macron(phi)_k / tau), quad tau = max(2.5 dot "sd"(macron(phi)), 10^(-6))
$

trong đó $tau$ tỷ lệ với độ lệch chuẩn của toàn bộ Giá trị Shapley toàn cục. Hạn ngạch (quota) cho mỗi cụm được tính theo tỷ lệ trọng số:

$
  "quota"_k = N^"strategy" w_k / sum_(j=1)^K w_j
$

Việc phân bổ được thực hiện sao cho tổng số điểm đúng bằng $N^"strategy"$, đồng thời đảm bảo mỗi cụm nhận tối thiểu $floor(N^"strategy" \/ (2K))$ điểm và không vượt quá số điểm còn lại của cụm sau khi đã loại bỏ tập $cal(D)^"eval"$. Với chiến lược *equal*, số điểm được chia đều; với chiến lược *max*, các cụm có Giá trị Shapley toàn cục nhỏ hơn (đóng góp làm giảm sai số) sẽ nhận được nhiều điểm hơn.

Cuối cùng, chúng ta huấn luyện 2 mô hình trên 2 tập dữ liệu tương ứng với 2 chiến lược và đánh giá trên tập $cal(D)^"eval"$ bằng sai số bình phương trung bình (MSE) cho từng cụm:

$
  "MSE"_k = 1/(n_k) sum_(t: x_t in cal(Q)_k) (y_t - f(x_t))^2
$

trong đó $n_k = 30$ là số điểm đánh giá của cụm $k$. Kết quả MSE theo từng tháng cho phép so sánh trực tiếp hiệu quả của 2 chiến lược, từ đó kiểm chứng liệu việc sử dụng Giá trị Shapley cho cụm dữ liệu để định hướng thu thập dữ liệu huấn luyện có giúp cải thiện độ chính xác dự đoán của mô hình hay không.

= Chương 5. KẾT LUẬN VÀ KIẾN NGHỊ

// KẾT LUẬN VÀ KIẾN NGHỊ: trình bày những phát hiện mới, những kết luận rút ra từ kết quả nghiên cứu; kiến nghị về những nghiên cứu tiếp theo;

= DANH MỤC TÀI LIỆU THAM KHẢO
