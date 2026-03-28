import { useState } from "react";
import {
  Search,
  Plus,
  Edit,
  Trash2,
  FileText,
  X,
} from "lucide-react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Textarea } from "./ui/textarea";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from "./ui/dialog";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "./ui/table";
import { Badge } from "./ui/badge";
import { toast } from "sonner";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "./ui/alert-dialog";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "./ui/accordion";

interface ProverbDefinition {
  id: string;
  meaning: string;
  usage?: string;
}

interface Proverb {
  id: string;
  text: string;
  category: string;
  definitions: ProverbDefinition[];
}

const initialProverbs: Proverb[] = [
  {
    id: "1",
    text: "Có công mài sắt có ngày nên kim",
    category: "Cần cù, kiên trì",
    definitions: [
      {
        id: "pd1",
        meaning:
          "Nếu kiên trì làm việc chăm chỉ thì sẽ có kết quả tốt đẹp",
        usage: "Dùng để khuyên người cần kiên trì trong học tập và công việc",
      },
    ],
  },
  {
    id: "2",
    text: "Ăn quả nhớ kẻ trồng cây",
    category: "Đạo đức, lương tâm",
    definitions: [
      {
        id: "pd2",
        meaning:
          "Nhắc nhở con người phải biết ơn người đã có công với mình",
        usage: "Dùng để nhắc nhở về lòng biết ơn",
      },
    ],
  },
  {
    id: "3",
    text: "Học thầy không tày học bạn",
    category: "Học tập",
    definitions: [
      {
        id: "pd3",
        meaning:
          "Việc học hỏi lẫn nhau giữa các bạn có khi còn quan trọng hơn việc học từ thầy",
        usage: "Nhấn mạnh tầm quan trọng của việc học hỏi từ bạn bè",
      },
    ],
  },
  {
    id: "4",
    text: "Một cây làm chẳng nên non, ba cây chụm lại nên hòn núi cao",
    category: "Đoàn kết",
    definitions: [
      {
        id: "pd4",
        meaning:
          "Sức mạnh tập thể luôn lớn hơn sức mạnh cá nhân",
        usage: "Khuyến khích tinh thần đoàn kết, hợp tác",
      },
    ],
  },
];

const categories = [
  "Cần cù, kiên trì",
  "Đạo đức, lương tâm",
  "Học tập",
  "Đoàn kết",
  "Tình bạn",
  "Gia đình",
  "Khác",
];

export default function ProverbManagement() {
  const [proverbs, setProverbs] = useState<Proverb[]>(initialProverbs);
  const [searchQuery, setSearchQuery] = useState("");
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [selectedProverb, setSelectedProverb] = useState<Proverb | null>(null);
  const [proverbToDelete, setProverbToDelete] = useState<Proverb | null>(null);

  const [formData, setFormData] = useState({
    text: "",
    category: categories[0],
    definitions: [{ meaning: "", usage: "" }],
  });

  const filteredProverbs = proverbs.filter((proverb) =>
    proverb.text.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleAddProverb = () => {
    const newProverb: Proverb = {
      id: Date.now().toString(),
      text: formData.text,
      category: formData.category,
      definitions: formData.definitions
        .filter((d) => d.meaning.trim() !== "")
        .map((d, index) => ({
          id: `pd${Date.now()}-${index}`,
          meaning: d.meaning,
          usage: d.usage || undefined,
        })),
    };

    setProverbs([...proverbs, newProverb]);
    setIsAddDialogOpen(false);
    resetForm();
    toast.success("Đã thêm tục ngữ thành công");
  };

  const handleEditProverb = () => {
    if (!selectedProverb) return;

    const updatedProverbs = proverbs.map((proverb) =>
      proverb.id === selectedProverb.id
        ? {
            ...proverb,
            text: formData.text,
            category: formData.category,
            definitions: formData.definitions
              .filter((d) => d.meaning.trim() !== "")
              .map((d, index) => ({
                id: `pd${Date.now()}-${index}`,
                meaning: d.meaning,
                usage: d.usage || undefined,
              })),
          }
        : proverb
    );

    setProverbs(updatedProverbs);
    setIsEditDialogOpen(false);
    setSelectedProverb(null);
    resetForm();
    toast.success("Đã cập nhật tục ngữ thành công");
  };

  const handleDeleteProverb = () => {
    if (!proverbToDelete) return;

    setProverbs(proverbs.filter((proverb) => proverb.id !== proverbToDelete.id));
    setIsDeleteDialogOpen(false);
    setProverbToDelete(null);
    toast.success("Đã xóa tục ngữ");
  };

  const openEditDialog = (proverb: Proverb) => {
    setSelectedProverb(proverb);
    setFormData({
      text: proverb.text,
      category: proverb.category,
      definitions: proverb.definitions.map((d) => ({
        meaning: d.meaning,
        usage: d.usage || "",
      })),
    });
    setIsEditDialogOpen(true);
  };

  const openDeleteDialog = (proverb: Proverb) => {
    setProverbToDelete(proverb);
    setIsDeleteDialogOpen(true);
  };

  const resetForm = () => {
    setFormData({
      text: "",
      category: categories[0],
      definitions: [{ meaning: "", usage: "" }],
    });
  };

  const addDefinitionField = () => {
    setFormData({
      ...formData,
      definitions: [...formData.definitions, { meaning: "", usage: "" }],
    });
  };

  const removeDefinitionField = (index: number) => {
    setFormData({
      ...formData,
      definitions: formData.definitions.filter((_, i) => i !== index),
    });
  };

  const updateDefinition = (
    index: number,
    field: "meaning" | "usage",
    value: string
  ) => {
    const updatedDefinitions = [...formData.definitions];
    updatedDefinitions[index][field] = value;
    setFormData({ ...formData, definitions: updatedDefinitions });
  };

  const ProverbFormDialog = ({
    isOpen,
    onClose,
    onSubmit,
    title,
  }: {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: () => void;
    title: string;
  }) => (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>
            {title === "Thêm tục ngữ mới"
              ? "Nhập thông tin chi tiết về tục ngữ"
              : "Chỉnh sửa thông tin tục ngữ"}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-4">
          <div className="space-y-2">
            <Label htmlFor="text">Câu tục ngữ *</Label>
            <Textarea
              id="text"
              value={formData.text}
              onChange={(e) =>
                setFormData({ ...formData, text: e.target.value })
              }
              placeholder="Nhập câu tục ngữ"
              rows={2}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="category">Danh mục *</Label>
            <select
              id="category"
              value={formData.category}
              onChange={(e) =>
                setFormData({ ...formData, category: e.target.value })
              }
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
            >
              {categories.map((cat) => (
                <option key={cat} value={cat}>
                  {cat}
                </option>
              ))}
            </select>
          </div>

          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <Label>Định nghĩa & Cách dùng *</Label>
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={addDefinitionField}
              >
                <Plus className="w-4 h-4 mr-2" />
                Thêm định nghĩa
              </Button>
            </div>

            {formData.definitions.map((def, index) => (
              <div key={index} className="border rounded-lg p-4 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">
                    Định nghĩa {index + 1}
                  </span>
                  {formData.definitions.length > 1 && (
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => removeDefinitionField(index)}
                    >
                      <X className="w-4 h-4" />
                    </Button>
                  )}
                </div>

                <div className="space-y-2">
                  <Label>Ý nghĩa</Label>
                  <Textarea
                    value={def.meaning}
                    onChange={(e) =>
                      updateDefinition(index, "meaning", e.target.value)
                    }
                    placeholder="Nhập ý nghĩa của tục ngữ"
                    rows={2}
                  />
                </div>

                <div className="space-y-2">
                  <Label>Cách dùng (tùy chọn)</Label>
                  <Textarea
                    value={def.usage}
                    onChange={(e) =>
                      updateDefinition(index, "usage", e.target.value)
                    }
                    placeholder="Nhập cách sử dụng tục ngữ"
                    rows={2}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Hủy
          </Button>
          <Button
            onClick={onSubmit}
            disabled={
              !formData.text ||
              formData.definitions.every((d) => !d.meaning.trim())
            }
          >
            {title === "Thêm tục ngữ mới" ? "Thêm" : "Cập nhật"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );

  return (
    <div className="p-8">
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              Quản lý tục ngữ
            </h1>
            <p className="text-gray-500 mt-2">
              Thêm, sửa, xóa các câu tục ngữ và định nghĩa
            </p>
          </div>
          <Button
            onClick={() => {
              resetForm();
              setIsAddDialogOpen(true);
            }}
          >
            <Plus className="w-4 h-4 mr-2" />
            Thêm tục ngữ mới
          </Button>
        </div>

        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <Input
            placeholder="Tìm kiếm tục ngữ..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
      </div>

      <div className="space-y-4">
        {filteredProverbs.length === 0 ? (
          <div className="bg-white rounded-lg border border-gray-200 p-12 text-center">
            <FileText className="w-12 h-12 mx-auto text-gray-300 mb-2" />
            <p className="text-gray-500">Không tìm thấy tục ngữ</p>
          </div>
        ) : (
          filteredProverbs.map((proverb) => (
            <div
              key={proverb.id}
              className="bg-white rounded-lg border border-gray-200 overflow-hidden"
            >
              <div className="p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-900 mb-2">
                      "{proverb.text}"
                    </h3>
                    <Badge variant="secondary">{proverb.category}</Badge>
                  </div>
                  <div className="flex items-center gap-2">
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => openEditDialog(proverb)}
                    >
                      <Edit className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => openDeleteDialog(proverb)}
                    >
                      <Trash2 className="w-4 h-4 text-red-500" />
                    </Button>
                  </div>
                </div>

                <Accordion type="single" collapsible className="w-full">
                  <AccordionItem value="definitions" className="border-none">
                    <AccordionTrigger className="text-sm font-medium hover:no-underline">
                      Xem định nghĩa ({proverb.definitions.length})
                    </AccordionTrigger>
                    <AccordionContent>
                      <div className="space-y-4 pt-2">
                        {proverb.definitions.map((def, index) => (
                          <div
                            key={def.id}
                            className="bg-gray-50 rounded-lg p-4"
                          >
                            <div className="flex items-start gap-3">
                              <span className="flex items-center justify-center w-6 h-6 rounded-full bg-blue-100 text-blue-700 text-sm font-medium flex-shrink-0">
                                {index + 1}
                              </span>
                              <div className="flex-1">
                                <p className="text-sm text-gray-900 mb-2">
                                  <span className="font-medium">Ý nghĩa:</span>{" "}
                                  {def.meaning}
                                </p>
                                {def.usage && (
                                  <p className="text-sm text-gray-600">
                                    <span className="font-medium">
                                      Cách dùng:
                                    </span>{" "}
                                    {def.usage}
                                  </p>
                                )}
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </AccordionContent>
                  </AccordionItem>
                </Accordion>
              </div>
            </div>
          ))
        )}
      </div>

      <ProverbFormDialog
        isOpen={isAddDialogOpen}
        onClose={() => setIsAddDialogOpen(false)}
        onSubmit={handleAddProverb}
        title="Thêm tục ngữ mới"
      />

      <ProverbFormDialog
        isOpen={isEditDialogOpen}
        onClose={() => {
          setIsEditDialogOpen(false);
          setSelectedProverb(null);
        }}
        onSubmit={handleEditProverb}
        title="Chỉnh sửa tục ngữ"
      />

      <AlertDialog
        open={isDeleteDialogOpen}
        onOpenChange={setIsDeleteDialogOpen}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Xác nhận xóa tục ngữ</AlertDialogTitle>
            <AlertDialogDescription>
              Bạn có chắc chắn muốn xóa tục ngữ "{proverbToDelete?.text}"? Tất
              cả các định nghĩa liên quan cũng sẽ bị xóa.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Hủy</AlertDialogCancel>
            <AlertDialogAction onClick={handleDeleteProverb}>
              Xóa
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
